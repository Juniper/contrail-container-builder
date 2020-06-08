#!/bin/bash -ex

mkdir -p /opt/plugin/site-packages /opt/plugin/python3/site-packages

# python3
cp -rf /opt/contrail_python3/site-packages/* /opt/plugin/python3/site-packages/
cp -rf /opt/contrail/site-packages/vnc_api* /opt/plugin/python3/site-packages/
cp -rf /opt/contrail/site-packages/cfgm_common* /opt/plugin/python3/site-packages/
cp -rf /opt/contrail/site-packages/contrail_heat* /opt/plugin/python3/site-packages/

# python2
cp -rf /opt/contrail/site-packages/* /opt/plugin/site-packages/
