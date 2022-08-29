# Build/run images within a container

[![build and push](https://github.com/djimenezc/podman-docker/actions/workflows/buildImage.yml/badge.svg)](https://github.com/djimenezc/podman-docker/actions/workflows/buildImage.yml)

Run podman within a container

Podman can be run in multiple ways, rootful and rootless. We end up with people wanting to run various combinations of rootful and rootless Podman:

- Rootful Podman in rootful Podman
- Rootless Podman in rootful Podman
- Rootful Podman in rootless Podman
- Rootless Podman in rootless Podman

## Links

- https://www.tutorialworks.com/podman-rootless-volumes/
- https://www.redhat.com/sysadmin/podman-inside-container
- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/managing_containers/finding_running_and_building_containers_with_podman_skopeo_and_buildah
- https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md
