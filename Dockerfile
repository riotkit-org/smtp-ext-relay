FROM marvambass/versatile-postfix

ENV BIFF=no \
    # Add domain
    APPEND_DOT_MYDOMAIN=no \
    # Outgoing mailer that sends to destination mailer server will use this certificate
    SMTPD_TLS_CERT_FILE=/etc/ssl/certs/ssl-cert-snakeoil.pem \
    SMTPD_TLS_KEY_FILE=/etc/ssl/private/ssl-cert-snakeoil.key \
    SMTP_TLS_CA_FILE=/etc/postfix/ssl/cacert.pem \
    SMTPD_USE_TLS=yes \
    MYHOSTNAME=localhost \
    MYDESTINATION=localhost \
    RELAY_HOST= \
    MAILBOX_SIZE_LIMIT=0 \
    RECIPIENT_DELIMITER=+ \
    SASL_AUTH_ENABLE=yes \
    TLS_SECURITY_LEVEL=may \
    HEADER_SIZE_LIMIT=4096000 \
    SMTPD_RECIPIENT_RESTRICTIONS="permit_mynetworks permit_sasl_authenticated reject_unauth_destination" \
    SMTPD_HELO_RESTRICTIONS="permit_sasl_authenticated, permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname" \
    SMTP_SASL_AUTH_ENABLE=yes \
    SMTP_SASL_SECURITY_OPTIONS=noanonymous \
    DELAY_WARNING_TIME=4h \
    SMTP_USE_TLS=yes

RUN apt-get update && apt-get install -y spamc python-pip \
    && useradd -ms /bin/false spamcuser \
    && pip install j2cli

ADD ./container-files/relay-setup-entrypoint.sh /bin/relay-setup-entrypoint.sh
ADD ./container-files/templates /templates
RUN chmod +x /bin/relay-setup-entrypoint.sh

ENTRYPOINT ["/bin/relay-setup-entrypoint.sh"]
