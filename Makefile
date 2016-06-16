# Makefile for creating container file
# Override these with environmental variables
BRANCH?=master
VERSION?=0.1.0

### Do not override below

user=hosh
app=rails-baseimage-23
build_dir=build
branch=$(BRANCH)
version=$(VERSION)
bundle_cache_dir=.cache/bundle
#registry=docker.io

all: container

container:
	docker build --tag=$(user)/$(app):$(version) .
	docker tag -f $(user)/$(app):$(version) $(user)/$(app):latest

push:
	docker push $(user)/$(app):$(version)

push-latest:
	docker push $(user)/$(app):latest

push-all: push push-latest

.PHONY: all container push push-latest push-all
