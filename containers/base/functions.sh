#!/bin/bash

function get_server_list() {
  local server_typ=$1_NODES
  local port_with_delim=$2
  local server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  local extended_server_list=''
  for server in "${server_list[@]}"; do
    local server_address=`echo ${server}`
    extended_server_list+=${server_address}${port_with_delim}
  done
  local extended_list="${extended_server_list::-1}"
  echo ${extended_list}
}

function get_cidr_for_nic() {
  local nic=$1
  ip address show dev $nic | grep "inet " | awk '{print $2}'
}

function get_default_nic() {
  ip route show | grep 'default via' | head -n 1 | awk '{print $5}'
}

function get_default_ip() {
  local nic=$(get_default_nic)
  get_cidr_for_nic $nic | awk -F '/' '{print($1)}'
}

function get_default_gateway_for_nic() {
  local nic=$1
  ip route show dev $nic | grep default | head -n 1 | awk '{print $3}'
}

function find_my_ip_and_order_for_node() {
  local server_typ=$1_NODES
  local server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  local local_ips=$(ip addr | awk '/inet/ {print($2)}')
  local ord=1
  for server in "${server_list[@]}"; do
    if [[ "$local_ips" =~ "$server" ]] ; then
      echo $server $ord
      return
    fi
    (( ord+=1 ))
  done
}

function get_vip_for_node() {
  local ip=$(find_my_ip_and_order_for_node $1 | cut -d ' ' -f 1)
  if [[ -z "$ip" ]] ; then
    local server_typ=$1_NODES
    ip=$(echo ${!server_typ} | cut -d',' -f 1)
  fi
  echo $ip
}

function get_listen_ip_for_node() {
  local ip=$(find_my_ip_and_order_for_node $1  | cut -d ' ' -f 1)
  if [[ -z "$ip" ]] ; then
    ip=$(get_default_ip)
  fi
  echo $ip
}

function get_order_for_node() {
  local order=$(find_my_ip_and_order_for_node $1 | cut -d ' ' -f 2)
  if [[ -z "$order" ]] ; then
    order=1
  fi
  echo $order
}

function get_vrouter_nic() {
  echo ${PHYSICAL_INTERFACE:-${DEFAULT_IFACE}}
}

function get_vrouter_mac() {
  local nic=$(get_vrouter_nic)
  cat /sys/class/net/${nic}/address
}

# It tries to resolve IP via local DBs (/etc/hosts, etc)
# if fails it then tries DNS lookup via the tool 'host'
function resolve_hostname_by_ip() {
  local ip=$1
  local
  local host_entry=$(getent hosts $ip | head -n 1)
  local name=''
  if  [ $? -eq 0 ] ; then
    name=$(echo $host_entry | awk '{print $2}' | awk -F '.' '{print $1}')
  else
    host_entry=$(host -4 $server)
    if [ $? -eq 0 ] ; then
      name=$(echo $host_entry | awk '{print $5}')
      name=${name::-1}
    fi
  fi
  if [[ "$name" != '' ]] ; then
    echo $name
  fi
}

# Generates a name by rule node-<ip>
# replacing '.' with '-' and sets it in the /etc/hosts
function generate_hostname_by_ip() {
  local ip=$1
  local name="node-"$(echo $srv | tr '.' '-')
  echo "$ip   $name" >> /etc/hosts
  echo $name
}

function get_hostname_by_ip() {
  local ip=$1
  local name=$(resolve_hostname_by_ip $ip)
  if [[ -z "$name" ]] ; then
    name=$(generate_hostname_for_ip $ip)
  fi
  echo $name
}
