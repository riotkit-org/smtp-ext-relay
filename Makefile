.PHONY: build
build:
	docker build . -t smtp-ext-relay

.PHONY: run
run:
	docker run --rm -p 2225:2225 -e MYHOSTNAME=riotkit.org -e USER_INTERNAL_NAME=internal -e REWRITE_FROM_ADDRESS=noreply@riotkit.org -e USER_INTERNAL_SECRET=test123  --name smtp smtp-ext-relay:latest riotkit.org

.PHONY: test
test:
	SUBJECT="Test Subject"; \
	TO="riotkit@riseup.net"; \
	MESSAGE="From: example@example.org\n\nHey There! This is a test mail"; \
	\
	echo $$MESSAGE | ssmtp -C ./ssmtp-test.conf -vvv $$TO

.PHONY: helm-test-install
helm-test-install:
	cd helm/smtp-ext-relay && \
	helm upgrade --install relay . -n smtp --create-namespace --values example-values/secrets.yaml
