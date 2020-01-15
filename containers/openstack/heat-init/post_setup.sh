#!/bin/bash
mkdir -p /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/contrail_heat* /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/cfgm_common* /opt/contrail/site-packages
rm -rf /usr/lib/python2.7/site-packages/contrail_heat*
rm -rf /usr/lib/python2.7/site-packages/vnc_api*
rm -rf /usr/lib/python2.7/site-packages/cfgm_common*
