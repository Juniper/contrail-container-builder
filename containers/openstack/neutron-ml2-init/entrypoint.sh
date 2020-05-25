#!/bin/bash -ex

mkdir -p /opt/plugin/site-packages
cp -rf /opt/contrail/usr/lib/python2.7/site-packages/* /opt/contrail/site-packages/* /opt/plugin/site-packages/
