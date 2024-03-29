FROM debian:bookworm-slim
MAINTAINER RiotKit

RUN apt-get update && apt-get install -y bash sudo wget postfix postfix-lmdb opendkim sasl2-bin rsyslog libsasl2-modules libsasl2-modules-db libsasl2-modules-ldap \
        opendkim python3 python3-pip python3-venv proxychains4 procps

# p2 (jinja2)
RUN wget https://github.com/wrouesnel/p2cli/releases/download/r13/p2-linux-x86_64 -O /usr/bin/p2 && chmod +x /usr/bin/p2

# multirun (supervisord equivalent)
RUN wget https://github.com/nicolas-van/multirun/releases/download/1.1.3/multirun-x86_64-linux-gnu-1.1.3.tar.gz -O /tmp/multirun.tar.gz \
    && cd /tmp \
    && tar xvf multirun.tar.gz \
    && rm multirun.tar.gz \
    && mv multir* /usr/bin/multirun \
    && chmod +x /usr/bin/multirun


# todo: do not use sudo
# todo: non-root container

ENV BIFF=no \
    # Banner
    SMTPD_BANNER="RiotKit SMTPD" \
    # With locally submitted mail, append the string ".$mydomain" to addresses that have no ".domain" information. With remotely submitted mail, append the string ".$remote_header_rewrite_domain" instead.
    APPEND_DOT_MYDOMAIN=no \
    # Certificate
    SMTPD_TLS_CERT_FILE=/etc/ssl/certs/ssl-cert-snakeoil.pem \
    # Certificate key
    SMTPD_TLS_KEY_FILE=/etc/ssl/private/ssl-cert-snakeoil.key \
    # Should the SMTPD exposed internally for applications use TLS? Recommended to use.
    SMTPD_USE_TLS=yes \
    # The default is to use the fully-qualified domain name (FQDN) from gethostname()
    MYHOSTNAME=localhost \
    # The list of domains that are delivered via the $local_transport mail delivery transport (defaults to localhost)
    MYDESTINATION=localhost \
    # The next-hop destination of non-local mail; overrides non-local domains in recipient addresses
    RELAY_HOST= \
    # The maximal size of any local(8) individual mailbox or maildir file, or zero (no limit). In fact, this limits the size of any file that is written to upon local delivery, including files written by external commands that are executed by the local(8) delivery agent.
    MAILBOX_SIZE_LIMIT=0 \
    # The set of characters that can separate a user name from its extension (example: user+foo), or a .forward file name from its extension (example: .forward+foo
    RECIPIENT_DELIMITER=+ \
    # Enable SASL authentication in the Postfix SMTP client. By default, the Postfix SMTP client uses no authentication (shell client)
    SASL_AUTH_ENABLE=yes \
    # The default SMTP TLS security level for the Postfix SMTP client; when a non-empty value is specified
    TLS_SECURITY_LEVEL=may \
    # The maximal amount of memory in bytes for storing a message header. If a header is larger, the excess is discarded.
    HEADER_SIZE_LIMIT=4096000 \
    # Optional restrictions that the Postfix SMTP server applies in the context of a client RCPT TO command
    SMTPD_RECIPIENT_RESTRICTIONS="permit_mynetworks permit_sasl_authenticated reject_unauth_destination" \
    # Optional restrictions that the Postfix SMTP server applies in the context of a client HELO command
    SMTPD_HELO_RESTRICTIONS="permit_sasl_authenticated, permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname" \
    # Enable SASL authentication in the Postfix SMTP client
    SMTP_SASL_AUTH_ENABLE=yes \
    # Postfix SMTP client SASL security options
    SMTP_SASL_SECURITY_OPTIONS=noanonymous \
    # After sending a "your message is delayed" notification, inform the sender when the delay clears up
    DELAY_WARNING_TIME=4h \
    # Use TLS in Postfix Client
    SMTP_USE_TLS=yes \
    # Outgoing mailer certificate
    SMTP_TLS_CA_FILE=/etc/postfix/ssl/cacert.pem \
    # DKIM
    ENABLE_DKIM=true \
    # Canonicalization is a process by which the headers and body of an email are converted to a canonical standard form before being signed (values: relaxed/simple)
    DKIM_CANONICALIZATION=simple \
    # To support multiple concurrent public keys per sending domain, the DNS namespace is further subdivided with "selectors". Selectors are arbitrary names below the "_domainkey." namespace. For example, selectors may indicate the names of your server locations (e.g., "mta1", "mta2", and "mta2"), the signing date (e.g., "january2005", "february2005", etc.), or even the individual user.
    DKIM_SELECTOR=mail \
    # /etc/aliases entries @todo: Better examples there
    ALIASES= \
    MY_NETWORKS= \
    REWRITE_FROM_ADDRESS= \
    SOCKS_PROXY_HOST= \
    SOCKS_PROXY_PORT=

RUN mkdir -p /etc/opendkim
ADD ./container-files/usr/local/bin/* /usr/local/bin/
ADD ./container-files/usr/lib/postfix/sbin/* /usr/lib/postfix/sbin/
ADD ./container-files/templates /templates
RUN chmod +x /usr/local/bin/* /usr/lib/postfix/sbin/*

# Prepare permissions, create structures
RUN mkdir -p /var/run/saslauthd /run/opendkim \
    && touch /var/log/mail.log /var/log/mail.err /var/log/mail.warn \
    && chmod a+rw /var/log/mail.* \
    && chown root:root /etc/postfix -R
RUN gpasswd -a postfix sasl

# Install setup & entrypoint modules
ADD requirements.txt /tmp/
RUN mkdir -p /var/lib/venv && python3 -m venv /var/lib/venv \
    && /bin/bash -c 'source /var/lib/venv/bin/activate; pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt'
ADD ./setupusers /opt/riotkit/setupusers
ENV PYTHONPATH=/opt/riotkit

HEALTHCHECK --interval=2m --timeout=3s \
  CMD /usr/local/bin/healthcheck.sh

EXPOSE "2225"

ENTRYPOINT ["/usr/local/bin/relay-setup-entrypoint.sh"]
