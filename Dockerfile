FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG PODMAN_PACKAGE=podman_4.4.0+ds1-1_${TARGETARCH}.deb
ARG TARGETARCH

RUN mkdir -p /etc/apt/keyrings

# Debian Testing/Bookworm
RUN curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/Debian_Testing/Release.key \
  | gpg --dearmor \
  | tee /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg > /dev/null
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg]\
    https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/Debian_Testing/ /" \
  | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list > /dev/null

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y  jq curl unzip \
    buildah skopeo podman conmon fuse-overlayfs \
    slirp4netns make qemu binfmt-support qemu-user-static qemu-system-arm && \
    if [ "${TARGETARCH}" = "arm64" ]; \
	then export ARCH_ENV=aarch64; \
	else export ARCH_ENV=x86_64; \
	fi && \
	curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH_ENV}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    aws --version && \
    apt remove -y unzip && \
    rm -rf /var/lib/apt/lists/* ./aws awscliv2.zip
