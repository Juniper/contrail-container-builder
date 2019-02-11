#!/bin/bash -ex

# linux distro here always centos for now
src_path='/usr/lib/python2.7/site-packages'

echo "INFO: passed OPENSTACK_VERSION is $OPENSTACK_VERSION"
if [[ -z "$OPENSTACK_VERSION" ]]; then
  echo "ERROR: OPENSTACK_VERSION is required to init neutron plugin correctly"
  exit 1
fi
# install appropriate version of python-neutron-lbaas based on OPENSTACK_VERSION
pkg_versions=([newton]=9 [ocata]=10 [pike]=11 [queens]=12 [rocky]=13)
pkg_version=${pkg_versions[$OPENSTACK_VERSION]}
if [[ -z "$pkg_version" ]]; then
  echo "ERROR: package version is not defined for this openstack version"
  exit 1
fi
pkg=$(ls -1 /opt/packages/ | grep -- "-.")
if [[ -z "$pkg" ]]; then
  echo "ERROR: package couldn't be found for this version: $pkg_version"
  ls -l /opt/packages/
  exit 1
fi
rpm -Uvh --nodeps /opt/packages/$pkg

mkdir -p /opt/plugin/site-packages
for module in neutron_plugin_contrail vnc_api cfgm_common neutron_lbaas ; do
  for item in `ls -d $src_path/${module}*` ; do
    cp -r $item /opt/plugin/site-packages/
  done
done
