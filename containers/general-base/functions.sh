#!/bin/bash

function is_enabled() {
  local val=${1,,}
  [[ "${val}" == 'true' || "${val}" == 'yes' || "${val}" == 'enabled' ]]
}

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

function get_default_nic() {
  ip route get 1 | grep -o "dev.*" | awk '{print $2}'
}

function get_cidr_for_nic() {
  local nic=$1
  ip addr show dev $nic | grep "inet .*/.* brd " | awk '{print $2}'
}

function get_listen_ip_for_nic() {
  # returns any IPv4 for nic
  local nic=$1
  get_cidr_for_nic $nic | cut -d '/' -f 1
}

function get_default_ip() {
  local nic=$(get_default_nic)
  get_cidr_for_nic $nic | cut -d '/' -f 1
}

function get_default_gateway_for_nic() {
  local nic=$1
  ip route show dev $nic | grep default | head -n 1 | awk '{print $3}'
}

function get_default_gateway_for_nic_metric() {
    local nic=$1
    local default_gw=`get_default_gateway_for_nic $nic`
    local default_gw_metric=`ip route show dev $nic | grep default | head -1 | grep -o "metric [0-9]*"`
    echo "$default_gw $default_gw_metric"
}

function get_local_ips() {
  cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}'
}

function find_my_ip_and_order_for_node() {
  local server_typ=$1_NODES
  local server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  local local_ips=",$(get_local_ips | tr '\n' ','),"
  local ord=1
  for server in "${server_list[@]}"; do
    if [[ "$local_ips" =~ ",$server," ]] ; then
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

function get_ctrl_data_iface() {
  local ctrl_data_network=$1
  local ctrl_data_nic=$(ip route get $ctrl_data_network | grep -oe "dev\s[[:graph:]]*" | awk '{print $2}')
  local default_nic=$(get_default_nic)

  #check if ctrl_data_nic and default_nic are same
  #if they are same nic then physical iface with ctrl_data_network does not exist

  if [ "$ctrl_data_nic" == "$default_nic" ] ; then
    return
  fi
  echo $ctrl_data_nic
}

function get_ctrl_data_listen_ip() {
  if [[ ! -z "$CONTROL_DATA_NET_LIST" ]]; then
    IFS=',' read -ra ctrl_data_net_list <<< "${CONTROL_DATA_NET_LIST}"
    for ctrl_data_network in "${ctrl_data_net_list[@]}"; do
      local ctrl_data_nic=$(get_ctrl_data_iface $ctrl_data_network)
      if [[ -n "$ctrl_data_nic" ]]; then
        get_listen_ip_for_nic $ctrl_data_nic
        break
      fi
    done
  fi
}

function get_listen_ip_for_node() {
  local ip=$(get_ctrl_data_listen_ip)
  if [[ -z "$ip" ]] ; then
    ip=$(find_my_ip_and_order_for_node $1  | cut -d ' ' -f 1)
  fi
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

function get_iface_mac() {
  local nic=$1
  cat /sys/class/net/${nic}/address
}

# It tries to resolve IP via local DBs (/etc/hosts, etc)
# if fails it then tries DNS lookup via the tool 'host'
function resolve_hostname_by_ip() {
  local ip=$1
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

function get_ip_for_vrouter_from_control() {
  local node=${CONTROL_NODES[0]}
  local iface=`ip route get $node | grep -o "dev.*" | awk '{print $2}'`
  get_listen_ip_for_nic $iface
}
