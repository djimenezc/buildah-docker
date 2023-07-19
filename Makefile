VERSION ?= latest

DOCKER_HUB ?= docker.io
DOCKER_IMAGE_NAME=djimenezc/podman
DOCKER_IMAGE_ID = $(DOCKER_HUB)/$(DOCKER_IMAGE_NAME)
DOCKER_IMAGE_URI=${DOCKER_IMAGE_ID}:${VERSION}
DOCKER_FILE ?= Dockerfile

DOCKER_PLATFORMS ?= linux/arm64,linux/amd64,linux/arm64/v8

K8S_NAMESPACE ?= david
PLATFORM ?= linux/amd64
#PLATFORM ?= linux/arm64,linux/amd64
IMG_NAME ?= test
IMG_VERSION ?= latest

AWS_REGION ?= eu-west-1
AWS_ACCOUNT=$(shell aws sts get-caller-identity --query 'Account' --output text)
HUB_NAME=$(AWS_ACCOUNT).dkr.ecr.${AWS_REGION}.amazonaws.com
REPO_NAME=$(HUB_NAME)/$(IMG_NAME)

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

docker-build-arm64:
	docker build \
	-f Dockerfile \
	--platform=linux/arm64 \
	--progress=plain \
	-t ${DOCKER_IMAGE_ID}:arm64 .

podman-ecr-login:
	aws ecr get-login-password | podman login --username AWS --password-stdin $(HUB_NAME)

podman-build:
	buildah build --jobs=4 --platform=${PLATFORM} --manifest shazam -f $(DOCKER_FILE) .
	skopeo inspect --raw containers-storage:localhost/shazam | \
	      jq '.manifests[].platform.architecture'
	buildah tag localhost/shazam $(REPO_NAME):$(IMG_VERSION)
	buildah tag localhost/shazam $(REPO_NAME):latest
	buildah manifest rm localhost/shazam

k8s-devspace-dev:
	devspace dev -n $(K8S_NAMESPACE)

k8s-devspace-remove:
	devspace purge -n $(K8S_NAMESPACE)

k8s-devspace-enter:
	devspace enter -n $(K8S_NAMESPACE)

k8s-devspace-sync:
	devspace sync --config=devspace.yaml -n $(K8S_NAMESPACE)

k8s-devspace-ui:
	devspace ui --config=devspace.yaml -n $(K8S_NAMESPACE)

k8s-devspace-use-context:
	devspace use context $(K8S_CONTEXT)
