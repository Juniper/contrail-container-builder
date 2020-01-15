#!/bin/bash
mkdir -p /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/neutron_plugin_contrail* /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages
/_prepare_packages.sh && rm -f /_prepare_packages.sh
