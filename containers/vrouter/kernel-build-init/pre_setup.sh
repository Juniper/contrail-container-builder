#!/bin/bash
mkdir -p /contrail_tools /vrouter_src
contrail_version=${CONTRAIL_VERSION:-$CONTRAIL_CONTAINER_TAG}
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends dkms
apt-get install -y --no-install-recommends yum yum-utils rpm2cpio cpio
