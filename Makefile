#!/usr/bin/env make -f

ORG ?= tcpcloud

all: aptly aptly-api aptly-publisher aptly-public

aptly:
	@echo "== Building $(ORG)/aptly .."
	(cd docker; docker build -t $(ORG)/aptly -f aptly.Dockerfile .)

aptly-api: aptly
	@echo "== Building $(ORG)/aptly-api .."
	(cd docker; docker build -t $(ORG)/aptly-api -f aptly-api.Dockerfile .)

aptly-publisher:
	@echo "== Building $(ORG)/aptly-publisher .."
	(cd docker; docker build -t $(ORG)/aptly-publisher -f aptly-publisher.Dockerfile .)

aptly-public:
	@echo "== Building $(ORG)/aptly-public .."
	(cd docker; docker build -t $(ORG)/aptly-public -f aptly-public.Dockerfile .)

push:
	docker push $(ORG)/aptly
	docker push $(ORG)/aptly-api
	docker push $(ORG)/aptly-publisher
	docker push $(ORG)/aptly-public
