#!/bin/bash -ex

# linux distro here always centos for now
src_path='/usr/lib/python2.7/site-packages'

mkdir -p /opt/plugin/site-packages
for module in neutron_plugin_contrail vnc_api cfgm_common ; do
  for item in `ls -d $src_path/${module}*` ; do
    cp -r $item /opt/plugin/site-packages/
  done
done
