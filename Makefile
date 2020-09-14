.PHONY: $(MAKECMDGOALS)

# `make setup` will be used after cloning or downloading to fulfill
# dependencies, and setup the the project in an initial state.
# This is where you might download rubygems, node_modules, packages,
# compile code, build container images, initialize a database,
# anything else that needs to happen before your server is started
# for the first time
setup:
	yarn install
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build web
	docker-compose run web bundle exec rake db:create
	docker-compose run web bundle exec rake db:migrate
	docker-compose down

# `make server` will be used after `make setup` in order to start
# an http server process that listens on any unreserved port
#	of your choice (e.g. 8080). 
server:
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up web

# `make test` will be used after `make setup` in order to run
# your test suite.
test:
	docker-compose run web yarn test
	docker-compose run web yarn testjs


CLEAN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(CLEAN_ARGS):;@:)

cleanup:
ifeq ($(strip $(CLEAN_ARGS)),volumes)
	$(eval REMOVE_VOLUME=--$(CLEAN_ARGS))
endif	
	docker-compose down $(REMOVE_VOLUME)
	rm -rf tmp