#!/bin/bash

set -e
set -x

VERSION_TAG=R5.1

# Make container for build
docker build --build-arg BRANCH=R5.1 --no-cache --tag tf5-sandbox:latest build-container

# Build everything inside sandbox
DOCKER_CMD="docker run -it --rm --mount type=bind,source=$(readlink -f repos),target=/root/contrail tf5-sandbox -- "
$DOCKER_CMD time scons -j4 --opt=production --without-dpdk --root=$(readlink -f build/install) install

# For future: how to build one component
# $DOCKER_CMD time scons --opt=production --without-dpdk contrail-control
# docker build -f service-containers/contrail-control.Dockerfile --tag contrail-control:$VERSION_TAG .

# Make containers from artifacts
docker build -f service-containers/contrail-config.Dockerfile --tag contrail-config:$VERSION_TAG .
docker build -f service-containers/contrail-control.Dockerfile --tag contrail-control:$VERSION_TAG .
docker build -f service-containers/contrail-dns.Dockerfile --tag contrail-dns:$VERSION_TAG .
docker build -f service-containers/contrail-named.Dockerfile --tag contrail-named:$VERSION_TAG .
docker build -f service-containers/contrail-webui.Dockerfile --tag contrail-webui:$VERSION_TAG .
docker build -f service-containers/contrail-vrouter-agent.Dockerfile --tag contrail-vrouter-agent:$VERSION_TAG .

