#!/bin/bash -x

DOCKER_HUB=docker.io
DOCKER_IMAGE_NAME=djimenezc/odc-multiarch-test
DOCKER_IMAGE_ID=${DOCKER_HUB}/${DOCKER_IMAGE_NAME}
DOCKER_IMAGE_URI=${DOCKER_IMAGE_ID}:${VERSION}

PLATFORM_ARCH=linux/arm64,linux/arm64/v8,linux/amd64

buildah build --jobs=4 --platform="${PLATFORM_ARCH}" --manifest shazam -f Dockerfile.owasp_dependency_check .
skopeo inspect --raw containers-storage:localhost/shazam
buildah tag localhost/shazam "${DOCKER_IMAGE_URI}"
buildah tag localhost/shazam "${DOCKER_IMAGE_ID}":latest
buildah manifest rm localhost/shazam

#	buildah manifest push --all $(DOCKER_IMAGE_URI) docker://$(DOCKER_IMAGE_URI)
#	buildah manifest push --all ${DOCKER_IMAGE_ID}:latest docker://${DOCKER_IMAGE_ID}:latest
