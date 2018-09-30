FROM marvambass/versatile-postfix

ADD ./container-files/relay-setup-entrypoint.sh /bin/relay-setup-entrypoint.sh
RUN chmod +x /bin/relay-setup-entrypoint.sh

RUN echo "transport_maps = hash:/etc/postfix/transport" >> /etc/postfix/main.cf \
    && echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf \
    && echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" >> /etc/postfix/main.cf \
    && echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf \
    && echo "smtp_tls_CAfile = /etc/postfix/ssl/cacert.pem" >> /etc/postfix/main.cf \
    && echo "smtp_use_tls = yes" >> /etc/postfix/main.cf

ENTRYPOINT ["/bin/relay-setup-entrypoint.sh"]
