#!/bin/bash -ex

# linux distro here always centos for now
lib_path='/usr/lib/python2.7/site-packages'

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
cp -rf /opt/contrail/usr/lib/python2.7/site-packages/* /opt/contrail/site-packages/* /opt/plugin/site-packages/
