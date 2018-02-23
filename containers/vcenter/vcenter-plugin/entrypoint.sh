#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-vcenter-plugin.conf << EOM
[DEFAULT]
# Vcenter plugin URL
vcenter.url = ${CONTRAIL_VCENTER_URL:-$VCENTER_SERVER}

#Vcenter credentials
vcenter.username = ${CONTRAIL_VCENTER_USERNAME:-$VCENTER_USERNAME} 
vcenter.password = ${CONTRAIL_VCENTER_PASSWORD:-$VCENTER_PASSWORD} 

vcenter.datacenter = ${CONTRAIL_VCENTER_DATACENTER:-$VCENTER_DATACENTER}
vcenter.dvswitch = ${CONTRAIL_VCENTER_CLUSTER:-$VCENTER_CLUSTER}
vcenter.ipfabricpg = ${CONTRAIL_VCENTER_IPFABRICPG:-$VCENTER_IPFABRICPG}

api.hostname = ${CONTRAIL_API_SERVER:-$CONFIG_SERVERS}
api.port = ${CONTRAIL_API_PORT:-8082}

zookeeper.serverlist = ${CONTRAIL_ANALYTICS_NODES}

introspect_port = ${CONTRAIL_VCENTER_PLUGIN_INTROSPECT_PORT:-8110}

EOM

set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
