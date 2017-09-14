.PHONY: image test

IMAGE_NAME ?= codeclimate/codeclimate-checkstyle
DOCKER_RUN = docker run --rm -w /usr/src/app -v $(PWD):/usr/src/app $(IMAGE_NAME)

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run -w /usr/src/app --rm $(IMAGE_NAME) rspec

upgrade:
	$(DOCKER_RUN) ./bin/upgrade.sh
	$(DOCKER_RUN) ./bin/scrape-docs
