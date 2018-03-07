#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-vcenter-plugin.conf << EOM
[DEFAULT]
# Vcenter plugin URL
vcenter.url = $VCENTER_SERVER

#Vcenter credentials
vcenter.username = $VCENTER_USERNAME
vcenter.password = $VCENTER_PASSWORD

vcenter.datacenter = $VCENTER_DATACENTER
vcenter.dvswitch = $VCENTER_CLUSTER
vcenter.ipfabricpg = ${VCENTER_IPFABRICPG:-'contrail-fab-pg'}

api.hostname = $CONFIG_SERVERS
api.port = $CONFIG_API_PORT

zookeeper.serverlist = ${ZOOKEEPER_NODES}:${ZOOKEEPER_PORT}

introspect_port = ${VCENTER_INTROSPECT_PORT:-8234}

EOM

set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"

