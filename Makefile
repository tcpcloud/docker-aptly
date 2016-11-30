#!/usr/bin/env make -f

all: aptly-api aptly-publisher

aptly-api:
	(cd docker; docker build -t tcpcloud/aptly-api -f aptly-api.Dockerfile .)

aptly-publisher:
	(cd docker; docker build -t tcpcloud/aptly-publisher -f aptly-publisher.Dockerfile .)
