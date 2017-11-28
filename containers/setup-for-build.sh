#!/bin/bash -e

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"

echo 'Contrail version: '$version
echo 'OpenStack version: '$os_version
echo 'Contrail registry: '$registry
echo 'Contrail repository: '$repository

# Define global variables

export CONTRAIL_VERSION=$version
export OPENSTACK_VERSION=$os_version
export CONTRAIL_REGISTRY=$registry
export CONTRAIL_REPOSITORY=$repository

export package_root_dir="/var/www"

if [ -n $CONTRAIL_REPOSITORY ]; then
  dir_prefix=$(echo $CONTRAIL_REPOSITORY | awk -F'/' '{print $4}' | sed 's/'$version'$//')
fi
export repo_dir="${package_root_dir}/${dir_prefix}${CONTRAIL_VERSION}"
if [ -d $repo_dir ]; then
  echo 'Remove existing packages in '$repo_dir
  rm -rf $repo_dir
fi
mkdir -p $repo_dir

# Run code

source "$DIR/install-http-server.sh"
if [[ "${BUILD_PACKAGES:-false}" == 'false' ]] ; then
  $DIR/install-repository.sh
else
  $DIR/build-repository.sh
fi
$DIR/unpack-vrouter-module.sh

$DIR/validate-docker.sh
$DIR/install-registry.sh
