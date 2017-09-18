.PHONY: image test

IMAGE_NAME ?= codeclimate/codeclimate-checkstyle
DOCKER_RUN_MOUNTED = docker run --rm -w /usr/src/app -v $(PWD):/usr/src/app

image:
	docker build --rm -t $(IMAGE_NAME) .

Gemfile.lock: image
	$(DOCKER_RUN_MOUNTED) --user root $(IMAGE_NAME) bundle install

test: image
	$(DOCKER_RUN_MOUNTED) $(IMAGE_NAME) rspec

upgrade:
	$(DOCKER_RUN_MOUNTED) $(IMAGE_NAME) ./bin/upgrade.sh
	$(DOCKER_RUN_MOUNTED) $(IMAGE_NAME) ./bin/scrape-docs
