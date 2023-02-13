.PHONY: image test release

IMAGE_NAME ?= codeclimate/codeclimate-checkstyle
RELEASE_REGISTRY ?= codeclimate
DOCKER_RUN_MOUNTED = docker run --rm --user=root -w /usr/src/app -v $(PWD):/usr/src/app

ifndef RELEASE_TAG
override RELEASE_TAG = latest
endif

image:
	docker build --rm -t $(IMAGE_NAME) .

Gemfile.lock: image
	$(DOCKER_RUN_MOUNTED) --user root $(IMAGE_NAME) bundle install

test: image
	$(DOCKER_RUN_MOUNTED) $(IMAGE_NAME) rspec

upgrade:
	$(DOCKER_RUN_MOUNTED) $(IMAGE_NAME) ./bin/upgrade.sh
	$(DOCKER_RUN_MOUNTED) $(IMAGE_NAME) ./bin/scrape-docs

release:
	docker tag $(IMAGE_NAME) $(RELEASE_REGISTRY)/codeclimate-checkstyle:$(RELEASE_TAG)
	docker push $(RELEASE_REGISTRY)/codeclimate-checkstyle:$(RELEASE_TAG)
