#!/bin/bash -e
# Sets up node for building containers. Parses common.env to get parameters (CONTRAIL_VERSION, CONTRAIL_REGISTRY,
# CONTRAIL_REPOSITORY, OPENSTACK_VERSION) or take them from environment.
# It installs http server, creates directory with rpm packages taken from PAKAGES_URL, install docker,
# installs docker-registry.

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"

echo 'Contrail version: '$CONTRAIL_VERSION
echo 'OpenStack version: '$OPENSTACK_VERSION
echo 'Contrail registry: '$CONTRAIL_REGISTRY
echo 'Contrail repository: '$CONTRAIL_REPOSITORY

# Define global variables
export package_root_dir="/var/www"

# TODO: do not download/install rpm repository if CONTRAIL_REPOSITORY is defined.
if [[ -n "$CONTRAIL_REPOSITORY" ]]; then
  dir_prefix=$(echo $CONTRAIL_REPOSITORY | awk -F'/' '{print $4}' | sed 's/'$CONTRAIL_VERSION-$OPENSTACK_VERSION'$//')
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

# TODO: do not installs local registry if external is provided.
$DIR/install-registry.sh
$DIR/config-test-registry.sh
