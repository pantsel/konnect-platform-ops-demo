# Description: Makefile for setting up the project

export VAULT_ADDR=http://localhost:8300
export VAULT_TOKEN=$(shell grep -o 'VAULT_TOKEN=\K.*' act.secrets)
KIND_CLUSTER_NAME=konnect-platform-ops-demo
RUNNER_IMAGE ?= pantsel/gh-runner:latest

prepare: check-deps gencerts actrc kind docker prep-secrets vault-secrets ## Prepare the project

actrc: ## Setup .actrc
	@echo "Setting up .actrc"
	@./scripts/prep-actrc.sh

gencerts: ## Generate certificates
	@echo "Generating certificates..."
	@./scripts/generate-certs.sh

prep-secrets: ## Prepare secrets
	@echo "Preparing secrets.."
	@./scripts/prep-act-secrets.sh

runner: ## Build the act runner docker image
	@echo "Building act runner image.."
	@./scripts/build-runner.sh $(RUNNER_IMAGE)

docker: ## Spin up docker containers
	@echo "Spinning up containers"
	@docker-compose up -d

kind: ## Setup kind cluster
	@echo "Setting up kind cluster.."
	@if ! kind get clusters | grep -q ${KIND_CLUSTER_NAME}; then \
		kind create cluster --name  ${KIND_CLUSTER_NAME}; \
	else \
		echo "Kind Cluster ${KIND_CLUSTER_NAME} already exists"; \
	fi

vault-secrets: ## Setup vault secrets
	@echo "Setting up vault secrets.."
	@./scripts/check-vault.sh
	@docker cp .tls vault:/tmp
	@docker exec -it vault vault kv put -address=$(VAULT_ADDR) secret/certificates/demo \
		tls_crt=@/tmp/.tls/tls.crt \
		tls_key=@/tmp/.tls/tls.key \
		ca=@/tmp/.tls/ca.crt
	@echo "Vault secrets setup completed"

check-deps: ## Check dependencies
	@echo "Checking dependencies.."
	@./scripts/check-deps.sh

stop: ## Stop all containers
	@echo "Stopping containers.."
	@docker-compose down

clean: stop ## Clean everything up
	@echo "Cleaning up.."
	@kind delete cluster --name  ${KIND_CLUSTER_NAME}
	@rm -rf .tls
	@rm -rf act.secrets
	@rm -rf .tmp

test: ## Run simple tests
	@echo "Running tests.."
	@./scripts/test.sh

help: ## Show this help
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\n"} \
	/^[a-zA-Z_-]+:.*##/ { printf "  %-15s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: prepare actrc gencerts prep-secrets kind docker vault-secrets clean stop check-deps test runner