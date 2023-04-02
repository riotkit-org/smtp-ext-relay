#!/bin/bash

set -e

#
# Original file from https://github.com/MarvAmBass/docker-versatile-postfix released under MIT license
#

echo ">> Setting up postfix for: ${MYHOSTNAME}"

# add domain
postconf -e myhostname="${MYHOSTNAME}"
postconf -e mydestination="${MYHOSTNAME}"
echo "${MYHOSTNAME}" > /etc/mailname
echo "Domain ${MYHOSTNAME}" >> /etc/opendkim.conf

# Configure /etc/opendkim/custom.conf file
cat <<EOF > /etc/opendkim/custom.conf
KeyFile                 /etc/postfix/dkim/dkim.key
Selector                $DKIM_SELECTOR
SOCKET                  inet:8891@localhost
EOF

##
# POSTFIX RAW Config ENVs
##
if env | grep '^PRC_'
then
  echo -e "\n## POSTFIX_RAW_CONFIG (PRC) ##\n" >> /etc/postfix/main.cf
  env | grep '^PRC_' | while read I_CONF
  do
    CONFD_CONF_NAME=$(echo "$I_CONF" | cut -d'=' -f1 | sed 's/PRC_//g' | tr '[:upper:]' '[:lower:]')
    CONFD_CONF_VALUE=$(echo "$I_CONF" | sed 's/^[^=]*=//g')

    echo "${CONFD_CONF_NAME} = ${CONFD_CONF_VALUE}" >> /etc/postfix/main.cf
  done
fi

# add aliases
#aliases-setup.sh

# DKIM
if [[ "${ENABLE_DKIM}" == "true" ]]
then
  if [[ -f /mnt/dkim-secret-volume/dkim.key ]]; then
      echo " >> Synchronizing secrets from /mnt/dkim-secret-volume to /etc/postfix/dkim"
      cp -pr -L /mnt/dkim-secret-volume/* /etc/postfix/dkim/
  fi

  echo ">> Enabling DKIM support"
  echo "   Canonicalization $DKIM_CANONICALIZATION" >> /etc/opendkim.conf

  postconf -e milter_default_action="accept"
  postconf -e milter_protocol="2"
  postconf -e smtpd_milters="inet:localhost:8891"
  postconf -e non_smtpd_milters="inet:localhost:8891"

  # Generate a key if there is no one
  if [ ! -f /etc/postfix/dkim/dkim.key ]
  then
    echo ">> No dkim.key found - generate one..."
    opendkim-genkey -s $DKIM_SELECTOR -d $1
    mkdir -p /etc/postfix/dkim/
    mv "/$DKIM_SELECTOR.private" /etc/postfix/dkim/dkim.key
    echo " >> Printing out public dkim key:"
    cat $DKIM_SELECTOR.txt
    mv $DKIM_SELECTOR.txt /etc/postfix/dkim/dkim.public
    echo " >> [!!!] Please add this key to your DNS System, you should also make sure that path /etc/postfix/dkim/ is in a persistent volume"
  fi
  echo " >> Change user and group of /etc/postfix/dkim/dkim.key to opendkim"
  chown -R opendkim:opendkim /etc/postfix/dkim/
  chmod -R o-rwX /etc/postfix/dkim/
  chmod o=- /etc/postfix/dkim/dkim.key

  echo " >> DKIM permissions:"
  ls -la /etc/postfix/dkim
fi

# disable chroot, not required in docker container
postconf -F smtp/inet/chroot=n

# ---------
# Transport
# ---------
entrypoint-setup-transport.sh

# starting services
echo " >> Starting processes"
PROCESSES=(
    "saslauthd -a sasldb -c -m /var/run/saslauthd -n 5 -d"
    "postfix start-fg"
    "tail -F /var/log/mail.*"
    "rsyslogd -n"
    "entrypoint-setup-users.sh"
)

if [[ "${ENABLE_DKIM}" == "true" ]] || [[ "${ENABLE_DKIM}" == "yes" ]]; then
    PROCESSES+=("opendkim -x /etc/opendkim.conf -A -f")
fi

echo " >> Running as $(id)}"

# todo
chmod 777 /etc/sasldb2

exec multirun "${PROCESSES[@]/#/}"
