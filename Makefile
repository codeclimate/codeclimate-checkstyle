.PHONY: image test

IMAGE_NAME ?= codeclimate/codeclimate-checkstyle

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run --rm $(IMAGE_NAME) sh -c "echo Nothing to do yet!"

upgrade:
	docker run --rm \
		--workdir /usr/src/app \
		--volume $(PWD):/usr/src/app \
		$(IMAGE_NAME) ./bin/upgrade.sh
