all: build push

build:
	sudo docker build . -f ./Dockerfile -t wolnosciowiec/smtp-ext-relay

push:
	sudo docker push wolnosciowiec/smtp-ext-relay
