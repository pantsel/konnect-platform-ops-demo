# Description: Makefile for setting up the project

export VAULT_ADDR=http://localhost:8300
export VAULT_TOKEN=$(shell grep -o 'VAULT_TOKEN=\K.*' act.secrets)
KIND_CLUSTER_NAME=konnect-platform-ops-demo

prepare: check-deps gencerts actrc kind docker prep-secrets vault-secrets

actrc:
	@echo "Setting up .actrc"
	@./scripts/prep-actrc.sh

gencerts:
	@echo "Generating certificates..."
	@./scripts/generate-certs.sh

prep-secrets:
	@echo "Preparing secrets.."
	@./scripts/prep-act-secrets.sh

docker:
	@echo "Spinning up containers"
	@docker-compose up -d

kind:
	@echo "Setting up kind cluster.."
	@if ! kind get clusters | grep -q ${KIND_CLUSTER_NAME}; then \
		kind create cluster --name  ${KIND_CLUSTER_NAME}; \
	else \
		echo "Kind Cluster ${KIND_CLUSTER_NAME} already exists"; \
	fi

vault-secrets:
	@echo "Setting up vault secrets.."
	@./scripts/check-vault.sh
	@docker cp .tls vault:/tmp
	@docker exec -it vault vault kv put -address=$(VAULT_ADDR) secret/certificates/demo \
		tls_crt=@/tmp/.tls/tls.crt \
		tls_key=@/tmp/.tls/tls.key \
		ca=@/tmp/.tls/ca.crt
	@echo "Vault secrets setup completed"

check-deps:
	@echo "Checking dependencies.."
	@./scripts/check-deps.sh

stop:
	@echo "Stopping containers.."
	@docker-compose down

clean: stop
	@echo "Cleaning up.."
	@kind delete cluster --name  ${KIND_CLUSTER_NAME}
	@rm -rf .tls
	@rm -rf act.secrets
	@rm -rf .tmp

.PHONY: prepare actrc gencerts prep-secrets kind docker vault-secrets clean stop check-deps