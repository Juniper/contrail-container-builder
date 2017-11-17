#!/bin/bash

set -ex
mkdir -p /opt/plugin/site-packages
for module in neutron_plugin_contrail vnc_api cfgm_common neutron_lbaas ; do
  for item in `ls -d /usr/lib/python2.7/site-packages/${module}*` ; do
    cp -r $item /opt/plugin/site-packages/
  done
done

cp /neutron-server.sh /opt/plugin/neutron-server.sh
