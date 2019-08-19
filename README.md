Postfix with optional external relays
=====================================

Simple docker image extending [marvambass/versatile-postfix](https://hub.docker.com/r/marvambass/versatile-postfix/).
Based on: https://serverfault.com/questions/660754/mail-sent-from-my-postfix-mail-server-goes-to-gmail-spam

Getting started
---------------

1. Generate SSL keys

```bash
openssl req -new -x509 -extensions v3_ca -keyout ./data/etc/postfix/ssl/cakey.pem -out ./data/etc/postfix/ssl/cacert.pem -days 3650
```

Adding external relay
---------------------

To add a relay just define a list of environment variables.
You can define as many relays as you want, but for each relay you need to fill all the information as on template below.

```bash
RELAY_xxx_ADDRESS=some.thing@gmail.com
RELAY_xxx_PASSWORD=yyy
RELAY_xxx_SMTP_DOMAIN=smtp.gmail.com
RELAY_xxx_SMTP_PORT=587
RELAY_xxx_EMAIL_DOMAIN=gmail.com
```

Example configuration
---------------------

```yaml
version: '2.3'
service:
    smtp:
        image: quay.io/riotkit/smtp:PUT-RELEASE-THERE
        expose:
            - "25"
        volumes:
            - ./data/etc/postfix/ssl/cakey.pem:/etc/postfix/ssl/cakey.pem
            - ./data/etc/postfix/ssl/cacert.pem:/etc/postfix/ssl/cacert.pem
        environment:
            BIFF: no
            APPEND_DOT_MYDOMAIN: no
            SMTPD_TLS_CERT_FILE: /etc/ssl/certs/ssl-cert-snakeoil.pem
            SMTPD_TLS_KEY_FILE: /etc/ssl/private/ssl-cert-snakeoil.key
            SMTP_TLS_CA_FILE: /etc/postfix/ssl/cacert.pem
            SMTPD_USE_TLS: yes
            MYHOSTNAME: localhost
            MYDESTINATION: localhost
            RELAY_HOST: 
            MAILBOX_SIZE_LIMIT: 0
            RECIPIENT_DELIMITER: +
            SASL_AUTH_ENABLE: yes
            TLS_SECURITY_LEVEL: may
            HEADER_SIZE_LIMIT: 4096000
            SMTPD_RECIPIENT_RESTRICTIONS: "permit_mynetworks permit_sasl_authenticated reject_unauth_destination"
            SMTPD_HELO_RESTRICTIONS: "permit_sasl_authenticated, permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname"
            SMTP_SASL_AUTH_ENABLE: yes
            SMTP_SASL_SECURITY_OPTIONS: noanonymous
            DELAY_WARNING_TIME: 4h
            SMTP_USE_TLS: yes
            

            # The relays are optional, they do not have to be defined
            # all mails could be sent just without any relay
            # redirect all recipient=*@gmail.com mails through gmail account
            - RELAY_GMAIL_ADDRESS=some.thing@gmail.com
            - RELAY_GMAIL_PASSWORD=yyy
            - RELAY_GMAIL_SMTP_DOMAIN=smtp.gmail.com
            - RELAY_GMAIL_SMTP_PORT=587
            - RELAY_GMAIL_EMAIL_DOMAIN=gmail.com

            # the same for outlook
            - RELAY_OUTLOOK_ADDRESS=some.thing@your-domain.org
            - RELAY_OUTLOOK_PASSWORD=yyy
            - RELAY_OUTLOOK_SMTP_DOMAIN=smtp.office365.com
            - RELAY_OUTLOOK_SMTP_PORT=587
            - RELAY_OUTLOOK_EMAIL_DOMAIN=your-domain.org
```

Configuration reference
-----------------------

List of all environment variables that could be used.

```yaml

- BIFF # (example value: no)
# # Add domain
- APPEND_DOT_MYDOMAIN # (example value: no)
# # Outgoing mailer that sends to destination mailer server will use this certificate
- SMTPD_TLS_CERT_FILE # (example value: /etc/ssl/certs/ssl-cert-snakeoil.pem)

- SMTPD_TLS_KEY_FILE # (example value: /etc/ssl/private/ssl-cert-snakeoil.key)

- SMTP_TLS_CA_FILE # (example value: /etc/postfix/ssl/cacert.pem)

- SMTPD_USE_TLS # (example value: yes)

- MYHOSTNAME # (example value: localhost)

- MYDESTINATION # (example value: localhost)

- RELAY_HOST # (example value: )

- MAILBOX_SIZE_LIMIT # (example value: 0)

- RECIPIENT_DELIMITER # (example value: +)

- SASL_AUTH_ENABLE # (example value: yes)

- TLS_SECURITY_LEVEL # (example value: may)

- HEADER_SIZE_LIMIT # (example value: 4096000)

- SMTPD_RECIPIENT_RESTRICTIONS # (example value: "permit_mynetworks permit_sasl_authenticated reject_unauth_destination")

- SMTPD_HELO_RESTRICTIONS # (example value: "permit_sasl_authenticated, permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname")

- SMTP_SASL_AUTH_ENABLE # (example value: yes)

- SMTP_SASL_SECURITY_OPTIONS # (example value: noanonymous)

- DELAY_WARNING_TIME # (example value: 4h)

- SMTP_USE_TLS # (example value: yes)

```

Custom main.cf and master.cf
-----------------------------

If after mounting main.cf as volume you get a lot of fatal errors such as `postconf: fatal: close /etc/postfix/main.cf.tmp: Device or resource busy`
then you can put your eg. `main.cf` at `/templates/etc/postfix/main.cf.j2` - it's contents will be securely copied to the /etc/postfix/main.cf

The same rule apply for the `master.cf`.
