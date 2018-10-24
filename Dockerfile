FROM marvambass/versatile-postfix

RUN apt-get update && apt-get install -y spamc

ADD ./container-files/relay-setup-entrypoint.sh /bin/relay-setup-entrypoint.sh
ADD ./container-files/etc/postfix/* /etc/postfix/
RUN chmod +x /bin/relay-setup-entrypoint.sh

ENTRYPOINT ["/bin/relay-setup-entrypoint.sh"]
