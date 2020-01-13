SHELL := /bin/bash
VERSION_TAG := $(shell git describe HEAD)
DB_VERSION_TAG := $(shell sha1sum db/init_import.sql.gz | cut -d ' ' -f 1 | cut -c1-8)

include CONFIG
export

DOCKER_COMPOSE_DEV := docker-compose -p $(PROJECT) -f docker-compose.yml -f docker-compose.dev.yml

.PHONY: help
help: ## help message, list all command
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

.PHONY: run 
run: ## run all needed container for dev
	$(DOCKER_COMPOSE_DEV) up

.PHONY: run-prod 
run-prod: ## run prod env without mounting the local code
	docker-compose -f docker-compose.yml -f docker-compose.devprod.yml up

.PHONY: shell-% 
shell-%: ## run all needed container for dev
	$(DOCKER_COMPOSE_DEV) exec $* /bin/sh

.PHONY:dumpdb 
dumpdb: ## dump the database from db container
	$(DOCKER_COMPOSE_DEV) exec db /bin/sh \
	-c 'mysqldump -uroot -p"$${MYSQL_ROOT_PASSWORD}" $(DB_NAME)' \
	> $(BACKUP_DIR)/mysql/$(DB_NAME)_local_$(shell date -Iseconds).sql

.PHONY:dumpdb-prod 
dumpdb-prod: ## dump the database from db container on prof
	ssh $(SWARM_MANAGER) 'sudo docker exec $$(sudo docker ps -q -f name=redtape-invoice_db) \
    /bin/bash -c "mysqldump -uroot -p\$${MYSQL_ROOT_PASSWORD} $(DB_NAME)"' \
	> $(BACKUP_DIR)/mysql/$(DB_NAME)_prod_$(shell date -Iseconds).sql

.PHONY:dumpdb-legacy
dumpdb-legacy: ## dump the database from db container on prof
	ssh $(LEGACY_MYSQL_HOST) "mysqldump -uroot -p $(LEGACY_DB_NAME)" \
	> $(BACKUP_DIR)/mysql/$(DB_NAME)_legacy_$(shell date -Iseconds).sql

.PHONY:dumpcode-legacy
dumpcode-legacy: ## dump the source code from the legacy system to ./src
	BACKUPPATH=$(BACKUP_DIR)/src/$(shell date -Iseconds); \
	mkdir -p $$BACKUPPATH ; \
	scp -r $(LEGACY_SRC_HOST):$(LEGACY_SRC_PATH)/* $$BACKUPPATH

.PHONY: build-images 
build-images: ## build all images locally
	envsubst '$${PROJECT_HOSTNAMES}' < web/nginx.conf.tpl > web/nginx.conf
	$(DOCKER_COMPOSE_DEV) build

.PHONY: push-images 
push-images: build-images ## build images and push to container registry
	docker tag ${REGISTRY_PREFIX}${PROJECT}-php ${REGISTRY_PREFIX}${PROJECT}-php:$(VERSION_TAG)
	docker tag ${REGISTRY_PREFIX}${PROJECT}-web ${REGISTRY_PREFIX}${PROJECT}-web:$(VERSION_TAG)
	docker tag ${REGISTRY_PREFIX}${PROJECT}-db ${REGISTRY_PREFIX}${PROJECT}-db:$(DB_VERSION_TAG)  
	docker push ${REGISTRY_PREFIX}${PROJECT}-php:$(VERSION_TAG)
	docker push ${REGISTRY_PREFIX}${PROJECT}-web:$(VERSION_TAG)
	docker push ${REGISTRY_PREFIX}${PROJECT}-db:$(DB_VERSION_TAG)
	docker push ${REGISTRY_PREFIX}${PROJECT}-php:latest
	docker push ${REGISTRY_PREFIX}${PROJECT}-web:latest
	docker push ${REGISTRY_PREFIX}${PROJECT}-db:latest

.PHONY: deploy-prod 
deploy-prod: push-images deploy-yml-prod initvolume-prod ## deploy docker-compose definition and pull images
	
.PHONY: deploy-yml-prod
deploy-yml-prod: ## deploy docker-compose definition
	envsubst '$${PROJECT_HOSTNAMES},$${REGISTRY_PREFIX},$${PROJECT},$${DB_NAME},$${PROJECT_URL}' < docker-compose.yml > docker-compose.yml.env
	scp docker-compose.yml.env $(SWARM_MANAGER):/tmp/${PROJECT}.yml
	rm docker-compose.yml.env
	ssh $(SWARM_MANAGER) "sudo mv /tmp/${PROJECT}.yml /opt/stacks"
	ssh $(SWARM_MANAGER) "sudo docker stack deploy --with-registry-auth --compose-file /opt/stacks/${PROJECT}.yml ${PROJECT}"

.PHONY: initvolume-prod
initvolume-prod: ## call volume init script in web container on prod when read
	ssh $(SWARM_MANAGER) 'while [ -z $$(sudo docker ps -q -f name=${PROJECT}_web) ]; do echo "container ${PROJECT}_web not ready...waiting"; sleep 5; done;'
	ssh $(SWARM_MANAGER) 'sudo docker exec $$(sudo docker ps -q -f name=${PROJECT}_web) sh /init_volume.sh'