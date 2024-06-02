# Description: Makefile for setting up the project

export VAULT_ADDR=http://localhost:8300
export VAULT_TOKEN=root

prepare: gencerts docker prep-secrets vault-secrets

gencerts:
	@echo "Generating certificates..."
	@./scripts/generate-certs.sh

prep-secrets:
	@echo "Preparing secrets.."
	@./scripts/prep-act-secrets.sh

docker:
	@echo "Spinning up containers"
	@docker-compose up -d

vault-secrets:
	@echo "Setting up vault secrets.."
	@./scripts/check-vault.sh
	@vault kv put secret/certificates/demo tls_crt=@.tls/tls.crt tls_key=@.tls/tls.key ca=@.tls/ca.crt
	@echo "Vault secrets setup completed"

.PHONY: prepare gencerts prep-secrets docker vault-secrets