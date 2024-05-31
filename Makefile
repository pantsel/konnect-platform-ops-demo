.PHONY: prepare
prepare: gencerts docker

.PHONY: gencerts
gencerts:
	@echo "Generating certificates..."
	@./scripts/generate-certs.sh

.PHONY: docker
docker:
	@echo "Spinning up containers"
	@docker-compose up -d

.PHONY: push
push:
	@echo "Simutating github push event"
	@act --env GITHUB_REPOSITORY=me/me   