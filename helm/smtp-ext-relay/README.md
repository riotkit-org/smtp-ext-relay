smtp-ext-relay Helm Chart
=========================

Simple SMTP server working on Kubernetes.

**Features:**
- Optionally route mails via external relays e.g. @gmail.com route via gmail.com account
- OpenDKIM
- TLS authentication
- Spam Assassin
- Supports [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets)
- Supports [cert-manager](https://cert-manager.io/)

Version v2.x was refactored to not depend on Python and Supervisord - instead lightweight Golang-based alternatives were used.


### [For more documentation read docs in GIT repository](https://github.com/riotkit-org/smtp-ext-relay)

Setting up
----------

Use helm to install `smtp-ext-relay`. For helm values please take a look at [values reference](https://github.com/riotkit-org/smtp-ext-relay/blob/main/helm/smtp-ext-relay/values.yaml).

```bash
helm repo add riotkit-org https://riotkit-org.github.io/helm-of-revolution/
helm install smtp riotkit-org/smtp-ext-relay
```
