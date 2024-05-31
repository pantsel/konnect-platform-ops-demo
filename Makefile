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
	@vault kv put secret/certificates/demo tls_crt=@.tls/tls.crt tls_key=@.tls/tls.key ca=@.tls/ca.crt
	@echo "Vault secrets setup completed"

act:
	@echo "Running github workflows.."
	@act --env GITHUB_REPOSITORY=me/me   

.PHONY: prepare gencerts prep-secrets docker vault-secrets act