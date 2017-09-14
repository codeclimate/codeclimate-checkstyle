.PHONY: image test

IMAGE_NAME ?= codeclimate/codeclimate-checkstyle
DOCKER_RUN = docker run --rm -w /usr/src/app -v $(PWD):/usr/src/app $(IMAGE_NAME)

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	$(DOCKER_RUN) sh -c "echo Nothing to do yet!"

upgrade:
	$(DOCKER_RUN) ./bin/upgrade.sh
	$(DOCKER_RUN) ./bin/scrape-docs
