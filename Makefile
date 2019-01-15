#!make
DOCKER_IMAGE_NAME:=ct-tech
DOCKER_IMAGE_TAG:=latest
DOCKER_CONTAINER_NAME:=tech-blog

build:
	@docker build -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) .

develop: build
	@docker run --rm --name $(DOCKER_CONTAINER_NAME) -d -p 4000:4000 -v $(PWD):/opt/ct -w /opt/ct $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

stop:
	@docker stop $(DOCKER_CONTAINER_NAME); docker rm $(DOCKER_CONTAINER_NAME) || true
