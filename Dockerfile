#FROM ubuntu:22.04 as builder
#
#RUN apt-get update && \
#    apt-get install -y curl
#
#RUN curl -o http://ftp.us.debian.org/debian/pool/main/libp/libpod/podman_4.2.0+ds1-3_arm64.deb

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y buildah skopeo curl awscli conmon fuse-overlayfs slirp4netns

RUN curl -O "http://ftp.us.debian.org/debian/pool/main/libp/libpod/podman_4.2.0+ds1-3_arm64.deb"  &&\
	dpkg --install podman_4.2.0+ds1-3_arm64.deb &&\
    rm podman_4.2.0+ds1-3_arm64.deb

RUN useradd podman; \
echo podman:10000:5000 > /etc/subuid; \
echo podman:10000:5000 > /etc/subgid;

VOLUME /var/lib/containers
VOLUME /home/podman/.local/share/containers

ADD https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/containers.conf /etc/containers/containers.conf
ADD https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/podman-containers.conf /home/podman/.config/containers/containers.conf
COPY ./config/storage.conf /etc/containers/storage.conf

# chmod containers.conf and adjust storage.conf to enable Fuse storage.
RUN chmod 644 /etc/containers/containers.conf;
RUN sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers /var/lib/shared/vfs-images /var/lib/shared/vfs-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock; touch /var/lib/shared/vfs-images/images.lock; touch /var/lib/shared/vfs-layers/layers.lock

RUN mkdir -p /home/podman/.local/share/containers/storage

RUN chown podman:podman -R /home/podman

ENV _CONTAINERS_USERNS_CONFIGURED=""

WORKDIR /home/podman
USER podman

