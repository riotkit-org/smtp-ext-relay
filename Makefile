.SILENT:
RIOTKIT_UTILS_VER=v1.0.2
SHELL=/bin/bash

all: build push

help:
	@grep -E '^[a-zA-Z\-\_0-9\.@]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:
	sudo docker build . -f ./Dockerfile -t wolnosciowiec/smtp-ext-relay

push:
	sudo docker push wolnosciowiec/smtp-ext-relay

before_commit: generate_readme ## Git hook before commit
	git add README.md

develop: ## Setup development environment, install git hooks
	echo " >> Setting up GIT hooks for development"
	mkdir -p .git/hooks
	echo "#\!/bin/bash\nmake before_commit" > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit

generate_readme: ## Generate the README.md
	[[ -f .helpers/extract-envs-from-dockerfile ]] || make _download_tools
	[[ -f .helpers/env-to-json ]] || make _download_tools

	# will produce DOCKERFILE_ENVS variable to include in j2cli
	cat Dockerfile | ./.helpers/extract-envs-from-dockerfile bash_source > .env.tmp; \
	source .env.tmp; \
	./.helpers/env-to-json parse_json | j2 ./README.md.j2 -f json > .README.md.tmp

	mv .README.md.tmp README.md
	rm .env.tmp

_download_tools:
	curl -s https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/extract-envs-from-dockerfile > .helpers/extract-envs-from-dockerfile
	curl -s https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/env-to-json > .helpers/env-to-json
	chmod +x .helpers/extract-envs-from-dockerfile .helpers/env-to-json
