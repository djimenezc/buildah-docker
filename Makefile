VERSION ?= latest

DOCKER_HUB ?= docker.io
DOCKER_IMAGE_NAME=djimenezc/buildah
DOCKER_IMAGE_ID = $(DOCKER_HUB)/$(DOCKER_IMAGE_NAME)
DOCKER_IMAGE_URI=${DOCKER_IMAGE_ID}:${VERSION}

docker-build:
	docker buildx build \
	--platform=linux/arm64 \
	-t ${DOCKER_IMAGE_URI} .

docker-ssh:
	docker run --privileged -it --rm --entrypoint='/bin/bash' ${DOCKER_IMAGE_URI}

docker-podman-run-test:
	docker run --privileged $(DOCKER_IMAGE_URI) podman run ubi8 echo hello

podman-test:
	podman run $(DOCKER_IMAGE_URI) podman run ubi8 echo
