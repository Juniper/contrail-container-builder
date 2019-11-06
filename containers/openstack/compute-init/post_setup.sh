#!/bin/bash
mkdir -p /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/vif_plug_vrouter* /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/vif_plug_contrail_vrouter* /opt/contrail/site-packages
cp -rf /usr/lib/python2.7/site-packages/nova_contrail_vif* /opt/contrail/site-packages
