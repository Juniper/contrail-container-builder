#!/bin/bash

set -ex

linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')
echo "INFO: detected linux id: $linux"
if [[ "$linux" == 'ubuntu' ]]; then
  src_path='/usr/lib/python2.7/dist-packages'
elif [[ "$linux" == 'centos' ]]; then
  src_path='/usr/lib/python2.7/site-packages'
else
  echo "ERROR: Distribution is not supported: $linux"
  exit 1
fi

mkdir -p /opt/plugin/site-packages
for module in contrail_heat vnc_api cfgm_common ; do
  for item in `ls -d $src_path/${module}*` ; do
    cp -r $item /opt/plugin/site-packages/
  done
done
