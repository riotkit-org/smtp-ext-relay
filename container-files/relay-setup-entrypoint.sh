#!/bin/bash

extract_relay_id () {
    env_name=$(echo ${1} | cut -d"=" -f1)
    without_ending=${env_name%%_EMAIL_DOMAIN}
    echo ${without_ending} | sed -e 's/RELAY_//'
}

get_relay_value () {
    eval "echo \${RELAY_${1}_${2}}"
}

enforce_line_in_file () {
    file=$1
    line=$2
    identify_by=$3

    if [[ ! -d $(dirname ${file}) ]]; then
        mkdir -p $(dirname ${file})
    fi

    if [[ ! -f ${file} ]]; then
        touch ${file}
    fi

    # remove old line
    if [[ ${identify_by} ]]; then
        cat ${file} | grep -v "${identify_by}" > /tmp/.identify-by
        cat /tmp/.identify-by > ${file}
    fi

    if [[ $(cat ${file}) != *"${line}"* ]]; then
        echo " [${file}]: ${line}"
        echo ${line} >> ${file}
        return 0
    fi

    echo "${file} is up to date"
}

copy_custom_postfix_conf () {
    if [[ -f /tmp/custom-main.cf ]]; then
        echo " >> Copying /tmp/custom-main.cf to /etc/postfix/main.cf"
        cat /tmp/custom-main.cf > /etc/postfix/main.cf
    fi

    if [[ -f /tmp/custom-master.cf ]]; then
        echo " >> Copying /tmp/custom-master.cf to /etc/postfix/master.cf"
        cat /tmp/custom-master.cf > /etc/postfix/master.cf
    fi
}

main () {
    touch /etc/postfix/sasl_passwd
    touch /etc/postfix/transport

    # iterate over all defined relays
    for current_relay in $(env |grep RELAY_|grep EMAIL_DOMAIN); do
        id=$(extract_relay_id ${current_relay})

        # RELAY_xxx_ADDRESS=some.thing@gmail.com
        # RELAY_xxx_PASSWORD=yyy
        # RELAY_xxx_SMTP_DOMAIN=smtp.gmail.com
        # RELAY_xxx_SMTP_PORT=587
        # RELAY_xxx_EMAIL_DOMAIN=gmail.com

        echo " >> Configuring relay ${id}"

        relay_smtp_domain=$(get_relay_value ${id} "SMTP_DOMAIN")
        relay_port=$(get_relay_value ${id} "SMTP_PORT")
        relay_mail=$(get_relay_value ${id} "ADDRESS")
        relay_passwd=$(get_relay_value ${id} "PASSWORD")
        relay_public_domain=$(get_relay_value ${id} "EMAIL_DOMAIN")

        if [[ ! ${relay_smtp_domain} ]] || [[ ! ${relay_port} ]] || [[ ! ${relay_public_domain} ]]; then
            echo " Invalid configuration for ${id}, missing one of env variables, examples:"
            echo " RELAY_${id}_ADDRESS=some.email@gmail.com # (optional)"
            echo " RELAY_${id}_PASSWORD=xxxyyy # (optional)"
            echo " RELAY_${id}_SMTP_DOMAIN=smtp.gmail.com"
            echo " RELAY_${id}_SMTP_PORT=587"
            echo " RELAY_${id}_EMAIL_DOMAIN=gmail.com"
            echo ""
            echo " Environment variables:"
            env
            exit 1
        fi

        enforce_line_in_file "/etc/postfix/sasl_passwd" "[${relay_smtp_domain}]:${relay_port} ${relay_mail}:${relay_passwd}" "${relay_mail}"
        enforce_line_in_file "/etc/postfix/transport" "${relay_public_domain} smtp:[${relay_smtp_domain}]:${relay_port}" "${relay_public_domain}"
    done

    sudo chown postfix:postfix /etc/postfix/ -R
    sudo chmod 400 /etc/postfix/sasl_passwd
    sudo postmap /etc/postfix/sasl_passwd
    sudo postmap /etc/postfix/transport

    copy_custom_postfix_conf
}

main
exec /opt/startup.sh "$@"
