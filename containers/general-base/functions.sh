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
  [ -n "$extended_server_list" ] && echo "${extended_server_list::-1}"
}

function get_default_nic() {
  ip route get 1 | grep -o "dev.*" | awk '{print $2}'
}

function get_cidr_for_nic() {
  local nic=$1
  ip addr show dev $nic | grep "inet " | awk '{print $2}' | head -n 1
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
  cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | grep -vi 'host' | sort | uniq
}

function find_my_ip_and_order_for_node() {
  local server_typ=$1_NODES
  find_my_ip_and_order_for_node_list ${!server_typ} 
}

function find_my_ip_and_order_for_node_list() {
  local servers=$1
  local server_list=''
  IFS=',' read -ra server_list <<< "$servers"
  local local_ips=",$(get_local_ips | tr '\n' ','),"
  local ord=1
  for server in "${server_list[@]}"; do
    local server_ip=''
    local ret=0
    if [ -f /hostname_to_ip ]; then
      server_ip=`/hostname_to_ip $server` || ret=$?
    else
      server_ip=`python -c "import socket; print(socket.gethostbyname('$server'))"` || ret=$?
    fi
    if [[ $ret == 0 && "$local_ips" =~ ",$server_ip," ]] ; then
      echo $server_ip $ord
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

function get_introspect_listen_ip_for_node() {
  local ip='0.0.0.0'
  if ! is_enabled ${INTROSPECT_LISTEN_ALL} ; then
    ip=$(get_listen_ip_for_node $1)
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

# It tries to resolve IP via local DBs (/etc/hosts, etc)
# if fails it then tries DNS lookup via the tool 'host'
function resolve_hostname_by_ip() {
  local ip=$1
  local host_entry=$(getent hosts $ip | head -n 1)
  local name=''
  if [[ -n "$host_entry" ]] ; then
    name=$(echo $host_entry | awk '{print $2}')
  elif host_entry=$(host -4 $server) ; then
    name=$(echo $host_entry | awk '{print $5}')
    name=${name::-1}
  fi
  if [[ -n "$name" ]] ; then
    echo $name
  fi
}

function get_iface_for_vrouter_from_control() {
  local node_ip=`echo $VROUTER_GATEWAY`
  if [[ -z "$node_ip" ]] ; then
    node_ip=`echo $CONTROL_NODES | cut -d ',' -f 1`
  fi
  local iface=$(ip route get $node_ip | grep -o "dev.*" | awk '{print $2}')
  if [[ "$iface" == 'lo' ]] ; then
    # ip is belong to this machine
    iface=`ip address show | grep "inet .*${node_ip}" | awk '{print($NF)}'`
  fi
  echo $iface
}

function get_ip_for_vrouter_from_control() {
  local iface=$(get_iface_for_vrouter_from_control)
  get_listen_ip_for_nic $iface
}

function mask2cidr() {
  local nbits=0
  local IFS=.
  for dec in $1 ; do
        case $dec in
            255) let nbits+=8;;
            254) let nbits+=7;;
            252) let nbits+=6;;
            248) let nbits+=5;;
            240) let nbits+=4;;
            224) let nbits+=3;;
            192) let nbits+=2;;
            128) let nbits+=1;;
            0);;
            *) echo "Error: $dec is not recognised"; exit 1
        esac
  done
  echo "$nbits"
}
