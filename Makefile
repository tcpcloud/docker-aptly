#!/usr/bin/env make -f

ORG ?= tcpcloud

all: aptly aptly-api aptly-publisher aptly-public

aptly:
	@echo "== Building $(ORG)/aptly .."
	(cd docker; docker build --no-cache -t $(ORG)/aptly -f aptly.Dockerfile .)
	@echo "== Tagging $(ORG)/aptly .."
	docker tag $(ORG)/aptly $(ORG)/aptly:$$(docker run --entrypoint=/usr/bin/aptly $(ORG)/aptly version|awk '{print $$3}'|tr -d '\r')

aptly-api: aptly
	@echo "== Building $(ORG)/aptly-api .."
	(cd docker; docker build -t $(ORG)/aptly-api -f aptly-api.Dockerfile .)
	@echo "== Tagging $(ORG)/aptly-api .."
	docker tag $(ORG)/aptly-api $(ORG)/aptly-api:$$(docker run --entrypoint=/usr/bin/aptly $(ORG)/aptly-api version|awk '{print $$3}'|tr -d '\r')

aptly-publisher:
	@echo "== Building $(ORG)/aptly-publisher .."
	(cd docker; docker build --no-cache -t $(ORG)/aptly-publisher -f aptly-publisher.Dockerfile .)
	@echo "== Tagging $(ORG)/aptly-publisher .."
	docker tag $(ORG)/aptly-publisher $(ORG)/aptly-publisher:$$(docker run --entrypoint=/usr/bin/pip $(ORG)/aptly-publisher show python-aptly --disable-pip-version-check|grep Version:|awk '{print $$2}'|tr -d '\r')

aptly-public:
	@echo "== Building $(ORG)/aptly-public .."
	(cd docker; docker build --no-cache -t $(ORG)/aptly-public -f aptly-public.Dockerfile .)

push:
	docker push $(ORG)/aptly
	docker push $(ORG)/aptly:$$(docker run --entrypoint=/usr/bin/aptly $(ORG)/aptly-api version|awk '{print $$3}'|tr -d '\r')
	docker push $(ORG)/aptly-api
	docker push $(ORG)/aptly-api:$$(docker run --entrypoint=/usr/bin/aptly $(ORG)/aptly-api version|awk '{print $$3}'|tr -d '\r')
	docker push $(ORG)/aptly-publisher
	docker push $(ORG)/aptly-publisher:$$(docker run --entrypoint=/usr/bin/pip $(ORG)/aptly-publisher show python-aptly --disable-pip-version-check|grep Version:|awk '{print $$2}'|tr -d '\r')
	docker push $(ORG)/aptly-public
