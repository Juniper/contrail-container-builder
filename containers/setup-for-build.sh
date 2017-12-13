#!/bin/bash -e
# Sets up node for building containers. Parses common.env to get parameters (CONTRAIL_VERSION, CONTRAIL_REGISTRY,
# CONTRAIL_REPOSITORY, OPENSTACK_VERSION) or take them from environment.

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
export PACKAGES_URL=$packages_url

export package_root_dir="/var/www"

if [[ -n "$CONTRAIL_REPOSITORY" ]]; then
  dir_prefix=$(echo $CONTRAIL_REPOSITORY | awk -F'/' '{print $4}' | sed 's/'$version'$//')
fi
export repo_dir="${package_root_dir}/${dir_prefix}${CONTRAIL_VERSION}-${OPENSTACK_VERSION}"
if [ -d $repo_dir ]; then
  echo 'Remove existing packages in '$repo_dir
  rm -rf $repo_dir
fi
sudo mkdir -p $repo_dir
sudo chown -R $USER $repo_dir

# Run code

sudo setenforce 0 || /bin/true
if [[ -f /etc/selinux/config && -n `grep "^[ ]*SELINUX[ ]*=" /etc/selinux/config` ]]; then
  sudo sed -i 's/^[ ]*SELINUX[ ]*=/SELINUX=permissive/g' /etc/selinux/config
else
  sudo bash -c "echo 'SELINUX=permissive' >> /etc/selinux/config"
fi


source "$DIR/install-http-server.sh"
$DIR/install-repository.sh

if [[ $TEST_MODE == 'true' ]] ; then
  $DIR/unpack-vrouter-module.sh
fi

$DIR/validate-docker.sh
$DIR/install-registry.sh
