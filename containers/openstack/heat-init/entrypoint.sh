#!/bin/bash

set -x

source /common.sh

set_vnc_api_lib_ini

# linux distro here always centos for now
src_path='/usr/lib/python2.7/site-packages'

mkdir -p /opt/plugin/site-packages
for module in contrail_heat vnc_api cfgm_common ; do
  for item in `ls -d $src_path/${module}*` ; do
    cp -r $item /opt/plugin/site-packages/
  done
done
