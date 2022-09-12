FROM bitnami/kubectl as kubectl

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG PODMAN_PACKAGE=podman_4.2.0+ds1-3_${TARGETARCH}.deb

RUN apt-get update && \
    apt-get install -y curl buildah skopeo awscli fuse-overlayfs \
    slirp4netns make qemu binfmt-support qemu-user-static qemu-system-arm \
    jq && \
    rm -rf /var/lib/apt/lists/*

ADD "http://ftp.us.debian.org/debian/pool/main/libp/libpod/${PODMAN_PACKAGE}" "${PODMAN_PACKAGE}"
RUN dpkg --install ${PODMAN_PACKAGE} && \
    rm ${PODMAN_PACKAGE}

RUN useradd podman; \
echo podman:10000:5000 > /etc/subuid; \
echo podman:10000:5000 > /etc/subgid;

VOLUME /var/lib/containers
VOLUME /home/podman/.local/share/containers

ADD https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/containers.conf /etc/containers/containers.conf
ADD https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/podman-containers.conf /home/podman/.config/containers/containers.conf
COPY ./config/storage.conf /etc/containers/storage.conf

# chmod containers.conf and adjust storage.conf to enable Fuse storage.
RUN chmod 644 /etc/containers/containers.conf; \
 sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers /var/lib/shared/vfs-images /var/lib/shared/vfs-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock; touch /var/lib/shared/vfs-images/images.lock; touch /var/lib/shared/vfs-layers/layers.lock

RUN mkdir -p /home/podman/.local/share/containers/storage /home/podman/images

RUN chown podman:podman -R /home/podman

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/

ENV _CONTAINERS_USERNS_CONFIGURED=""

WORKDIR /home/podman

