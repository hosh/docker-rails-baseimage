# Makefile for creating container file
# Override these with environmental variables
BRANCH?=master
VERSION?=0.2.0

### Do not override below

user=shopapps
app=rails-baseimage-22
build_dir=build
repo=../../.git
repo_dir=alt-text
branch=$(BRANCH)
version=$(VERSION)
bundle_cache_dir=.cache/bundle
builder=phusion/passenger-ruby22:0.9.18
#registry=registry.shopapps.co

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

