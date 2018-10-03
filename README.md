Postfix with external relays
============================

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

```yaml
version: '2'
service:
    smtp:
        image: wolnosciowiec/smtp-with-relays
        expose:
            - "25"
        volumes:
            - ./data/etc/postfix/ssl/cakey.pem:/etc/postfix/ssl/cakey.pem
            - ./data/etc/postfix/ssl/cacert.pem:/etc/postfix/ssl/cacert.pem
        environment:
            - RELAY_GMAIL_ADDRESS=some.thing@gmail.com
            - RELAY_GMAIL_PASSWORD=yyy
            - RELAY_GMAIL_SMTP_DOMAIN=smtp.gmail.com
            - RELAY_GMAIL_SMTP_PORT=587
            - RELAY_GMAIL_EMAIL_DOMAIN=gmail.com
              
            - RELAY_OUTLOOK_ADDRESS=some.thing@your-domain.org
            - RELAY_OUTLOOK_PASSWORD=yyy
            - RELAY_OUTLOOK_SMTP_DOMAIN=smtp.office365.com
            - RELAY_OUTLOOK_SMTP_PORT=587
            - RELAY_OUTLOOK_EMAIL_DOMAIN=your-domain.org
```

Custom main.cf
--------------

If after mounting main.cf as volume you get a lot of fatal errors such as `postconf: fatal: close /etc/postfix/main.cf.tmp: Device or resource busy`
then you can put your eg. `main.cf` at `/tmp/custom-main.cf` - it's contents will be securely copied to the /etc/postfix/main.cf

The same rule apply for the `master.cf`.
