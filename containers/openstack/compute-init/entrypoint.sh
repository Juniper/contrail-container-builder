#!/bin/bash -ex

mkdir -p /opt/plugin/bin
cp /opt/contrail/bin/* /opt/plugin/bin/
mkdir -p /opt/plugin/site-packages
cp -rf /opt/contrail/site-packages/* /opt/plugin/site-packages/
