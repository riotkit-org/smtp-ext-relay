all: build push

build:
	sudo docker build . -f ./Dockerfile -t wolnosciowiec/smtp-with-relays

push:
	sudo docker push wolnosciowiec/smtp-with-relays
