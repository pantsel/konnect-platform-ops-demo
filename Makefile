# Description: Makefile for setting up the project

export VAULT_ADDR=http://localhost:8300
export VAULT_TOKEN=$(shell awk -F '=' '/VAULT_TOKEN/ {print $$2}' act.secrets)
export GITHUB_ORG=$(shell awk -F '=' '/GITHUB_ORG/ {print $$2}' act.secrets)
export GH_MINIO_OIDC_APP_CLIENT_ID=$(shell awk -F '=' '/GH_MINIO_OIDC_APP_CLIENT_ID/ {print $$2}' act.secrets)
export GH_MINIO_OIDC_APP_CLIENT_SECRET=$(shell awk -F '=' '/GH_MINIO_OIDC_APP_CLIENT_SECRET/ {print $$2}' act.secrets)
KIND_CLUSTER_NAME=konnect-platform-ops-demo
RUNNER_IMAGE ?= pantsel/gh-runner:latest

prepare: check-deps gencerts actrc docker prep-act-secrets kind vault-pki setup-minio-gh-auth ## Prepare the project

prepare-aws:
	@echo "Preparing AWS.."
	@./scripts/aws/setup-s3.sh
	@./scripts/aws/create_github_oidc_provider.sh 

actrc: ## Setup .actrc
	@echo "Setting up .actrc"
	@./scripts/prep-actrc.sh

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

setup-minio-gh-auth: ## Setup minio gh auth
	@echo "Setting up minio gh auth.."
	@./scripts/setup-minio-gh-auth.sh $(GH_MINIO_OIDC_APP_CLIENT_ID) $(GH_MINIO_OIDC_APP_CLIENT_SECRET)
	
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

.PHONY: prepare actrc gencerts prep-act-secrets kind docker vault-secrets vault-pki clean stop check-deps test runner