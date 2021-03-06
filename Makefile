DOCKER_COMPOSE_DIR=./.docker
DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_DIR)/docker-compose.yml
DEFAULT_CONTAINER=workspace
DOCKER_COMPOSE=docker-compose -f $(DOCKER_COMPOSE_FILE) --project-directory $(DOCKER_COMPOSE_DIR)
DB_USER=api-platform

DEFAULT_GOAL := help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ [Docker] Build / Infrastructure
.docker/.env:
	cp $(DOCKER_COMPOSE_DIR)/.env.example $(DOCKER_COMPOSE_DIR)/.env

# .PHONY: docker-clean
# docker-clean: ## Remove the .env file for docker
# 	rm -f $(DOCKER_COMPOSE_DIR)/.env

.PHONY: docker-clean
docker-clean: docker-init ## Build all docker images from scratch, without cache etc. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) rm -fs $(CONTAINER)

.PHONY: docker-init
docker-init: .docker/.env ## Make sure the .env file exists for docker

.PHONY: docker-build-from-scratch
docker-build-from-scratch: docker-init ## Build all docker images from scratch, without cache etc. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) rm -fs $(CONTAINER) && \
	$(DOCKER_COMPOSE) build --pull --no-cache --parallel $(CONTAINER) && \
	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

.PHONY: docker-test
docker-test: docker-init docker-up ## Run the infrastructure tests for the docker setup
	sh $(DOCKER_COMPOSE_DIR)/docker-test.sh

.PHONY: docker-build
docker-build: docker-init ## Build all docker images. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) build --parallel $(CONTAINER) && \
	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

.PHONY: docker-prune
docker-prune: ## Remove unused docker resources via 'docker system prune -a -f --volumes'
	docker system prune -a -f --volumes

.PHONY: docker-up
docker-up: docker-init ## Start all docker containers. To only start one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) up -d $(CONTAINER)

.PHONY: docker-down
docker-down: docker-init ## Stop all docker containers. To only stop one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) down $(CONTAINER)

.PHONY: docker-bash
docker-bash: docker-init ## Sh into a container. Use CONTAINER=<service>
	$(DOCKER_COMPOSE) run --rm $(CONTAINER) /bin/bash

.PHONY: docker-ps
docker-ps: docker-init ## List all docker containers
	$(DOCKER_COMPOSE) ps

.PHONY: docker-logs
docker-logs: docker-init ## List all docker containers
	$(DOCKER_COMPOSE) logs $(CONTAINER)

.PHONY: docker-run-composer
docker-run-composer: docker-init ## runs composer commands CMD=<COMMAND TO RUN>
	$(DOCKER_COMPOSE) run workspace composer $(CMD)

.PHONY: docker-run-console
docker-run-console: docker-init ## runs php bin/console commands CMD=<COMMAND TO RUN>
	$(DOCKER_COMPOSE) run workspace php bin/console $(CMD)

.PHONY: docker-run-yarn
docker-run-yarn: docker-init ## runs yarn add instead of install(npm) commands CMD=<COMMAND TO RUN>
	$(DOCKER_COMPOSE) run node yarn $(CMD)
	# $(DOCKER_COMPOSE) run node su node sh -c "npm $(CMD)"

.PHONY: docker-run-npm
docker-run-npm: docker-init ## runs yarn add instead of install(npm) commands CMD=<COMMAND TO RUN>
	$(DOCKER_COMPOSE) run node npm $(CMD)
	# $(DOCKER_COMPOSE) run node su node sh -c "npm $(CMD)"

.PHONY: workspace-cmd
workspace-cmd: docker-init ## run bash type commands in workspace
	$(DOCKER_COMPOSE) run workspace $(CMD)

.PHONY: docker-node-cmd
docker-node-cmd: docker-init ## run bash type commands in workspace
	$(DOCKER_COMPOSE) run node $(CMD)
	# $(DOCKER_COMPOSE) run node su node sh -c "$(CMD)"
# .PHONY: docker-run-psql
# docker-run-psql: docker-init ## runs npm commands CMD=<COMMAND TO RUN>
# 	$(DOCKER_COMPOSE) run db psql $(CMD)

.PHONY: db
# `EXEC_LIVE` must be set at runtime only,
# because of the run rule, that must first end up with new containers PIDs.
db: ## some db shenanigans
	$(eval EXEC_LIVE := exec -ti $(shell docker ps -f name=db -q) su root sh -c)
	# docker ${EXEC_LIVE} "cat /var/lib/postgresql/data/pg_hba.conf"
	# docker ${EXEC_LIVE} "ls -lah /var/lib/postgresql/data/"
	docker ${EXEC_LIVE} "$(CMD)"
	# docker ${EXEC_LIVE} "cat /etc/passwd"
	# docker ${EXEC_LIVE} "find / -type f -iname 'postgres*'"
	# docker ${EXEC_LIVE} "createuser -d -s ${DB_USER}"
	# docker ${EXEC_LIVE} "createdb  -T template0 -E UTF8 -U ${DB_USER} ${DB_NAME}"
	# docker ${EXEC_LIVE} "psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};\""
	# docker ${EXEC_LIVE} "psql -c \"ALTER USER ${DB_USER} PASSWORD '${DB_PWD}';\"";

.PHONY: create-db
create-db: db ## creates db named DB_NAME=<new db name>
	docker ${EXEC_LIVE} "createdb -T template0 -E UTF8 -U ${DB_USER} ${DB_NAME}"

.PHONY: docker-restart-db
docker-restart-db: docker-init ## Restart the docker container and thus the db service
	$(DOCKER_COMPOSE) "restart" $(CONTAINER)


## $(eval EXEC_LIVE := exec -ti $(shell docker ps -f name=db -q) psql \l -U api-platform -d template1)
# docker ${EXEC_LIVE} "'psql -t' api-platform"
# $(DOCKER_COMPOSE) run db psql
# docker ${EXEC_LIVE} "createdb -T template0 -E UTF8 -U api-platform a_test"
# docker logs $(docker ps -f name=nginx -q)
# docker logs $(docker ps -f name=final_attempt_nginx_1 -q)
# docker logs $(docker ps -f name=final_attempt_php_1 -q)
# docker logs $(docker ps -f name=final_attempt_adminer_1 -q)
# docker-compose down
# docker-compose exec php composer install --prefer-dist
# docker-compose exec workspace composer install --prefer-dist
# docker-compose exec node <node/vue commands>
# docker-compose build php
# docker-compose up -d
# cmds: psql -U api-platform postgres -c 'SELECT pg_reload_conf();'
# docker-compose exec php composer install --prefer-dist
# docker-compose exec php composer create-project symfony/skeleton okta-start
# docker-compose exec php composer require annotations
# docker-compose exec php composer require flex
# docker-compose exec php composer require symfony/flex
# docker-compose exec php composer require annotations
# docker-compose exec php composer require sec-checker --dev
# docker-compose exec php composer require twig
# docker-compose exec php composer require profiler --dev
# docker-compose exec php composer require debug --dev
# docker-compose exec php composer unpack debug
# docker-compose exec php composer create-project symfony/website-skeleton start
# docker-compose exec php composer require symfony/flex
# docker-compose exec php composer require sec-checker --dev
# docker-compose exec php composer require profiler --dev
# docker-compose exec php composer require debug --dev
# docker-compose exec php composer unpack debug
# bin/app composer require sensio/framework-extra-bundle
# make docker-run-composer CMD='require nelmio/cors-bundle'
# make docker-run-composer CMD='require sec-checker'
# make docker-run-composer CMD='require annotations'
