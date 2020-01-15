#!/bin/bash
mkdir -p /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/neutron_plugin_contrail* /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/cfgm_common* /opt/contrail/site-packages
rm -rf /usr/lib/python2.7/site-packages/neutron_plugin_contrail*
rm -rf /usr/lib/python2.7/site-packages/vnc_api*
rm -rf /usr/lib/python2.7/site-packages/cfgm_common*
yum autoremove -y
/_prepare_packages.sh && rm -f /_prepare_packages.sh
