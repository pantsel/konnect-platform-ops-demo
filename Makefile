# Description: Makefile for setting up the project

export VAULT_ADDR=http://localhost:8300
export VAULT_TOKEN=$(shell grep -o 'VAULT_TOKEN=\K.*' act.secrets)
export GITHUB_ORG=$(shell grep -o 'GITHUB_ORG=\K.*' act.secrets)
KIND_CLUSTER_NAME=konnect-platform-ops-demo
RUNNER_IMAGE ?= pantsel/gh-runner:latest

prepare: check-deps gencerts actrc build_images docker prep-act-secrets kind vault-pki ## Prepare the project

actrc: ## Setup .actrc
	@echo "Setting up .actrc"
	@./scripts/prep-actrc.sh

build_images: ## Build docker images
	@echo "Building docker images.."
	@docker build -t kongair/flights-api:latest -f ./examples/apiops/apis/flights/Dockerfile ./examples/apiops/apis/flights
	@docker build -t kongair/routes-api:latest -f ./examples/apiops/apis/routes/Dockerfile ./examples/apiops/apis/routes

gencerts: ## Generate certificates
	@echo "Generating certificates..."
	@./scripts/generate-certs.sh

prep-act-secrets: ## Prepare secrets
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

	@KUBE_CONTEXT=$$(grep KUBE_CONTEXT act.secrets | cut -d '=' -f2); \
	if [ "$$KUBE_CONTEXT" != "orbstack" ]; then \
		if ! kind get clusters | grep -q ${KIND_CLUSTER_NAME}; then \
			kind create cluster --name  ${KIND_CLUSTER_NAME}; \
		else \
			echo "Kind Cluster ${KIND_CLUSTER_NAME} already exists"; \
		fi; \
	else \
		echo "Skipping kind cluster creation. Using orbstack."; \
	fi

vault-secrets: ## Setup vault secrets
	@echo "Setting up vault secrets.."
	@./scripts/check-vault.sh
	@docker cp .tls vault:/tmp
	@if ! vault secrets list | grep -q 'konnect'; then \
		vault secrets enable -path=konnect kv-v2; \
	else \
		echo "Vault secrets path 'konnect' already exists"; \
	fi
	@docker exec -it vault vault kv put -address=$(VAULT_ADDR) konnect/certificates \
		cluster_crt=@/tmp/.tls/cluster-tls.crt \
		cluster_key=@/tmp/.tls/cluster-tls.key \
		proxy_crt=@/tmp/.tls/proxy-tls.crt \
		proxy_key=@/tmp/.tls/proxy-tls.key \
		ca=@/tmp/.tls/ca.crt

vault-pki: ## Setup vault pki
	@echo "Setting up vault pki."
	@./scripts/check-vault.sh
	@docker exec vault chmod +x /vault-pki-setup.sh
	@docker exec -it vault /vault-pki-setup.sh $(VAULT_ADDR) $(VAULT_TOKEN) $(GITHUB_ORG)
	
check-deps: ## Check dependencies
	@echo "Checking dependencies.."
	@./scripts/check-deps.sh

stop: ## Stop all containers
	@echo "Stopping containers.."
	@docker-compose down

clean: stop ## Clean everything up
	@echo "Cleaning up.."
	@KUBE_CONTEXT=$$(grep KUBE_CONTEXT act.secrets | cut -d '=' -f2); \
	if [ "$$KUBE_CONTEXT" != "orbstack" ]; then \
		kind delete cluster --name  ${KIND_CLUSTER_NAME}; \
	else \
		orb delete k8s; \
	fi
	@rm -rf .tls
	@rm -rf act.secrets
	@rm -rf .tmp

test: ## Run simple tests
	@echo "Running tests.."
	@./scripts/test-workflows.sh

help: ## Show this help
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\n"} \
	/^[a-zA-Z_-]+:.*##/ { printf "  %-15s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: prepare actrc gencerts prep-act-secrets kind docker vault-secrets vault-pki clean stop check-deps test runner build_images