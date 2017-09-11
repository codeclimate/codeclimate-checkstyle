.PHONY: image test

IMAGE_NAME ?= codeclimate/codeclimate-checkstyle

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run --rm $(IMAGE_NAME) sh -c "echo Nothing to do yet!"
