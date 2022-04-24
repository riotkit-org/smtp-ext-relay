.PHONY: build
build:
	docker build . -t smtp-ext-relay

.PHONY: run
run:
	docker run --rm -p 2225:2225 -e MYHOSTNAME=anarchista.net  --name smtp smtp-ext-relay:latest anarchista.net internal:test123

.PHONY: test
test:
	SUBJECT="Test Subject"; \
	TO="example@example.org"; \
	MESSAGE="From: example@example.org\n\nHey There! This is a test mail"; \
	\
	echo $$MESSAGE
	 | ssmtp -vvv $$TO

.PHONY: helm-test-install
helm-test-install:
	cd helm/smtp-ext-relay && \
	helm upgrade --install relay . -n smtp --create-namespace --values example-values/secrets.yaml
