#!/bin/bash

source /common.sh

api_hostname=${CONFIG_API_VIP:-$(get_vip_for_node CONFIG)}

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

api.hostname=$api_hostname
api.port=$CONFIG_API_PORT

zookeeper.serverlist=$ZOOKEEPER_SERVERS

$contrail_stats_collector
EOM

add_ini_params_from_env VCENTER_PLUGIN /etc/contrail/contrail-vcenter-plugin.conf

set_vnc_api_lib_ini

exec $@
