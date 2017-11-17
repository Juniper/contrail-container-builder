#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"

echo 'Contrail version: '$version
echo 'OpenStack version: '$os_version
echo 'Contrail registry: '$registry
echo 'Contrail repository: '$repository

CONTRAIL_VERSION=$version
OPENSTACK_VERSION=$os_version
CONTRAIL_REGISTRY=$registry
CONTRAIL_REPOSITORY=$repository

source "$DIR/install-repository.sh"
$DIR/validate-docker.sh
source "$DIR/install-registry.sh"
