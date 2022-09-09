VERSION ?= latest

DOCKER_HUB ?= docker.io
DOCKER_IMAGE_NAME=djimenezc/podman
DOCKER_IMAGE_ID = $(DOCKER_HUB)/$(DOCKER_IMAGE_NAME)
DOCKER_IMAGE_URI=${DOCKER_IMAGE_ID}:${VERSION}

DOCKER_PLATFORMS ?= linux/arm64,linux/amd64,linux/arm64/v8

docker-build:
	docker buildx build \
	--platform=$(DOCKER_PLATFORMS) \
	-t ${DOCKER_IMAGE_URI} .

docker-ssh:
	docker run --privileged -it --rm --entrypoint='/bin/bash'  -v ${PWD}/src:/home/podman/src ${DOCKER_IMAGE_URI}

docker-podman-run-test:
	docker run --rm --privileged -v ${PWD}/mycontainers:/home/podman/.local/share/containers $(DOCKER_IMAGE_URI) podman run ubi8 echo hello

docker-podman-build-test:
	docker run --rm --privileged -v ${PWD}/src:/home/podman/src $(DOCKER_IMAGE_URI) podman build -t hello-world ./src

docker-podman-build-ODC:
	docker run --rm --privileged -v ${PWD}/src:/home/podman/src $(DOCKER_IMAGE_URI) podman build -t odc-single-arch ./src -f Dockerfile.owasp_dependency_check

docker-podman-build-ODC-multiarch:
	docker run --rm --privileged -v ${PWD}/src:/home/podman $(DOCKER_IMAGE_URI) /home/podman/build-multiarch.sh
