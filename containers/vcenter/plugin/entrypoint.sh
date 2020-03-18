#!/bin/bash

source /common.sh

# TODO: implement using list of IP-s/Names in vcenter-plugin
# to be able to pass a list of config-api server here.
# and remove next block after.
function get_vip_for_node() {
  local ip=$(find_my_ip_and_order_for_node $1 | cut -d ' ' -f 1)
  if [[ -z "$ip" ]] ; then
    local server_typ=$1_NODES
    ip=$(echo ${!server_typ} | cut -d',' -f 1)
  fi
  echo $ip
}
api_hostname=${CONFIG_API_VIP:-$(get_vip_for_node CONFIG)}

mkdir -p /etc/contrail
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

$collector_stats_config
EOM

add_ini_params_from_env VCENTER_PLUGIN /etc/contrail/contrail-vcenter-plugin.conf

set_vnc_api_lib_ini

exec $@
