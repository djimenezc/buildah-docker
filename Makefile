VERSION ?= latest

DOCKER_HUB ?= docker.io
DOCKER_IMAGE_NAME=djimenezc/podman
DOCKER_IMAGE_ID = $(DOCKER_HUB)/$(DOCKER_IMAGE_NAME)
DOCKER_IMAGE_URI=${DOCKER_IMAGE_ID}:${VERSION}

export PLATFORM_ARCH=linux/arm64,linux/arm64/v8,linux/amd64

docker-build:
	docker buildx build \
	--platform=linux/arm64,linux/amd64,linux/arm64/v8 \
	-t ${DOCKER_IMAGE_URI} .

docker-ssh:
	docker run --privileged -it --rm --entrypoint='/bin/bash'  -v ${PWD}/src:/home/podman/src ${DOCKER_IMAGE_URI}

docker-podman-run-test:
	docker run --rm --privileged -v ${PWD}/mycontainers:/home/podman/.local/share/containers $(DOCKER_IMAGE_URI) podman run ubi8 echo hello

docker-podman-build-test:
	docker run --rm --privileged -v ${PWD}/src:/home/podman/src $(DOCKER_IMAGE_URI) podman build -t hello-world ./src

docker-podman-build-ODC:
	docker run --rm --privileged -v ${PWD}/src:/home/podman/src $(DOCKER_IMAGE_URI) podman build -t hello-world ./src -f Dockerfile.owas_dependency_check

docker-podman-build-ODC-multiarch:
	buildah build --jobs=4 --platform=${PLATFORM_ARCH} --manifest shazam .
	skopeo inspect --raw containers-storage:localhost/shazam | \
          jq '.manifests[].platform.architecture'
	buildah tag localhost/shazam $(DOCKER_IMAGE_URI)
	buildah tag localhost/shazam ${DOCKER_IMAGE_ID}:latest
	buildah manifest rm localhost/shazam
#	buildah manifest push --all $(DOCKER_IMAGE_URI) docker://$(DOCKER_IMAGE_URI)
#	buildah manifest push --all ${DOCKER_IMAGE_ID}:latest docker://${DOCKER_IMAGE_ID}:latest
