#!/bin/bash -ex

mkdir -p /opt/plugin/site-packages /opt/plugin/python3/site-packages

# python3
cp -rf /opt/contrail/python3/site-packages/* /opt/plugin/python3/site-packages
cp -rf /opt/contrail/site-packages/* /opt/plugin/python3/site-packages

# python2
cp -rf /opt/contrail/python2/site-packages/* /opt/plugin/site-packages/
cp -rf /opt/contrail/site-packages/* /opt/plugin/site-packages/
