#!/bin/bash -ex

mkdir -p /opt/plugin/site-packages /opt/plugin/python3/site-packages

# python3
cp -rf /opt/contrail_python3/site-packages/* /opt/plugin/python3/site-packages/

# python2
cp -rf /opt/contrail/site-packages/* /opt/plugin/site-packages/
