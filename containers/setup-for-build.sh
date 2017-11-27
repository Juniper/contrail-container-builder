#!/bin/bash -e

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"

echo 'Contrail version: '$version
echo 'OpenStack version: '$os_version
echo 'Contrail registry: '$registry
echo 'Contrail repository: '$repository

export CONTRAIL_VERSION=$version
export OPENSTACK_VERSION=$os_version
export CONTRAIL_REGISTRY=$registry
export CONTRAIL_REPOSITORY=$repository

package_root_dir="/var/www"

source "$DIR/install-http-server.sh"
if [[ "$BUILD_PACKAGES" == 'true' ]] ; then
  source "$DIR/install-repository.sh"
else
  echo "INFO: BUILD_PACKAGES is true - run build..."
  # all paths are hardcoded here...
  $HOME/contrail-build-poc/build.sh
  sudo mkdir -p $package_root_dir/$CONTRAIL_VERSION
  sudo cp $HOME/rpmbuild/RPMS/x86_64/*.rpm $package_root_dir/$CONTRAIL_VERSION/
  sudo cp $HOME/rpmbuild/RPMS/noarch/*.rpm $package_root_dir/$CONTRAIL_VERSION/
  pushd $package_root_dir/$CONTRAIL_VERSION/
  sudo yum install -y createrepo
  sudo createrepo .
  popd
fi
$DIR/unpack-vrouter-module.sh
$DIR/validate-docker.sh
$DIR/install-registry.sh
