#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-vcenter-plugin.conf << EOM
[DEFAULT]
# Vcenter plugin URL
vcenter.url=https://$VCENTER_SERVER/sdk

#Vcenter credentials
vcenter.username=$VCENTER_USERNAME
vcenter.password=$VCENTER_PASSWORD

vcenter.datacenter=$VCENTER_DATACENTER
vcenter.dvswitch=$VCENTER_DVSWITCH
vcenter.ipfabricpg=${VCENTER_IPFABRICPG:-contrail-fab-pg}

api.hostname=$CONFIG_API_VIP
api.port=$CONFIG_API_PORT

zookeeper.serverlist=$ZOOKEEPER_SERVERS

EOM

add_ini_params_from_env VCENTER_PLUGIN /etc/contrail/contrail-vcenter-plugin.conf

set_vnc_api_lib_ini

wait_for_contrail_api

exec $@

