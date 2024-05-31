# Description: Makefile for setting up the project
prepare: gencerts docker
	@echo "Creating required files and directories.."
	@mkdir -p .tmp
	@if [ ! -f act.secrets ]; then \
		touch act.secrets; \
		echo "KONNECT_PAT=your_konnect_pat_token" >> act.secrets; \
		echo "S3_ACCESS_KEY=your_s3_access_key" >> act.secrets; \
		echo "S3_SECRET_KEY=your_s3_secret_key" >> act.secrets; \
	else \
		echo "act.secrets file already exists"; \
	fi

gencerts:
	@echo "Generating certificates..."
	@./scripts/generate-certs.sh

docker:
	@echo "Spinning up containers"
	@docker-compose up -d

act:
	@echo "Running github workflows.."
	@act --env GITHUB_REPOSITORY=me/me   

.PHONY: prepare gencerts docker act