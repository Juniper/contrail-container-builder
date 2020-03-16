#!/bin/bash -ex

# linux distro here always centos for now
lib_path='/usr/lib/python2.7/site-packages'

# some containers with neutron-server have neutron_lbaas and some don't.
# and we can't check presense of this library inside neutron-server in init contrainer.
# due to this fact we may need to bring own version of neutron-lbaas into neutron-server container.
# rhel container with neuton-server has this package installed and therefore we don't need to bring own.
# try to find stored package with python-neutron-lbaas-$OPENSTACK_VERSION, install it and copy to /opt/plugin/site-packages

echo "INFO: passed OPENSTACK_VERSION is $OPENSTACK_VERSION"
if [[ -z "$OPENSTACK_VERSION" ]]; then
  echo "ERROR: OPENSTACK_VERSION is required to init neutron plugin correctly"
  exit 1
fi

function copy_sources() {
  local src_path=$1
  local module=$2
  for item in `ls -d $src_path/${module}*` ; do
    cp -r $item /opt/plugin/site-packages/
  done
}

mkdir -p /opt/plugin/site-packages
cp -rf /opt/contrail/site-packages/* /opt/plugin/site-packages/

# install appropriate version of python-neutron-lbaas based on OPENSTACK_VERSION
pkg=$(ls -1 /opt/packages/ | grep python-neutron-lbaas-$OPENSTACK_VERSION || true)
if [[ -z "$pkg" ]]; then
  # rhel case
  echo "INFO: package couldn't be found for this version: $pkg_version. Available packages:"
  ls -l /opt/packages/ || true
else
  mkdir -p /tmp/lbaas
  pushd /tmp/lbaas
  # rpm install can't be used here cause this container can be run under non-root user
  rpm2cpio /opt/packages/$pkg | cpio -idmv
  copy_sources usr/lib/python2.7/site-packages neutron_lbaas
  popd
  rm -rf /tmp/lbaas
fi
