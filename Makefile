# Makefile for creating container file
# Override these with environmental variables
BRANCH?=master
VERSION?=master

### Do not override below

user=shopapps
app=alt-text
build_dir=build
repo=../../.git
repo_dir=alt-text
branch=$(BRANCH)
version=$(VERSION)
bundle_cache_dir=.cache/bundle
builder=phusion/passenger-ruby22:0.9.17
#registry=registry.shopapps.co

all: $(build_dir)/$(repo_dir) container

container: $(build_dir)/$(repo_dir) assets
	docker build --tag=$(user)/$(app):$(version) .
	docker tag -f $(user)/$(app):$(version) $(user)/$(app):latest
	# docker tag -f $(user)/$(app):$(version) $(registry)/$(app):$(version)


assets: $(build_dir)/$(repo_dir) $(build_dir)/shopapps-kit $(build_dir)/shopify_api_metal $(bundle_cache_dir)
	# Use our own comple of bundle config so we can cache the gems
	# -v $(PWD)/etc/bundle.config:/build/.bundle/config
	# -v $(PWD)/$(bundle_cache_dir):/cache/bundle
	docker run --rm \
	  -w /build \
	  -v $(PWD)/../../gems:/gems \
	  -v $(PWD)/tools/precompile-assets:/precompile-assets \
	  -v $(PWD)/$(build_dir)/$(repo_dir):/build \
	  -v $(PWD)/$(bundle_cache_dir):/build/vendor/bundle \
	  -v $(SSH_AUTH_SOCK):/ssh-agent \
	  -e SSH_AUTH_SOCK=/ssh-agent \
	  -e DATABASE_URL=postgres://root@postgresql/alt_text \
	  -e RUBYGEMS_PROXY_URL=http://rubygems-proxy \
	  $(builder) \
	  /precompile-assets

$(build_dir)/$(repo_dir): $(build_dir)
	git -C $(build_dir) clone --shared --recursive $(repo) $(repo_dir)
	git -C $(build_dir)/$(repo_dir) checkout -q $(branch)
	rm -fr $(build_dir)/$(repo_dir)/.git
	# Configure files
	cp $(build_dir)/$(repo_dir)/config/app.yml.example $(build_dir)/$(repo_dir)/config/app.yml
	cp $(build_dir)/$(repo_dir)/config/shards.yml.example $(build_dir)/$(repo_dir)/config/shards.yml
	# Change to dev group (9999)
	docker run --rm \
	  -v $(PWD)/$(build_dir)/$(repo_dir):/build \
	  $(builder) \
	  chown -R 9999:9999 /build
	docker run --rm -i -t \
	  -v $(PWD)/$(bundle_cache_dir):/cache/bundle \
	  $(builder) \
	  chown -R 9999:9999 /cache

$(build_dir)/shopapps-kit: $(build_dir)
	git -C $(build_dir) clone --depth=1 --branch=master --single-branch --recursive git@github.com:shopappsio/shopapps-kit.git
	rm -fr $(build_dir)/shopapps-kit/.git

$(build_dir)/shopify_api_metal: $(build_dir)
	git -C $(build_dir) clone --depth=1 --branch=master --single-branch --recursive git@github.com:shopappsio/shopify_api_metal.git
	rm -fr $(build_dir)/shopify_api_metal/.git

$(bundle_cache_dir):
	mkdir -p $(bundle_cache_dir)

$(build_dir):
	mkdir $(build_dir) || true

clean:
	docker run --rm -v $(PWD):/_build \
	$(builder) \
	  rm -fr /_build/$(build_dir)

.PHONY: clean all container assets

