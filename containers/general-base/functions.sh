#!/bin/bash

function is_enabled() {
  local val=${1,,}
  [[ "${val}" == 'true' || "${val}" == 'yes' || "${val}" == 'enabled' ]]
}

function format_boolean() {
  # python's ConfigParser understand only True/False in PascalCase
  if is_enabled $1 ; then
    echo 'True'
  else
    echo 'False'
  fi
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

function get_gateway_nic_for_ip() {
    local ip=$1
    local iface=$(ip route get $ip | grep -o "dev.*" | awk '{print $2}')
    if [[ "$iface" == 'lo' ]] ; then
      # ip is belong to this machine
      iface=$(ip address show | grep -m 1 -F "inet ${ip}/" | awk '{print($NF)}')
    fi
    echo $iface
}

function get_default_nic() {
  get_gateway_nic_for_ip 1
}

function get_cidr_for_nic() {
  local nic=$1
  ip addr show dev $nic | grep "inet " | awk '{print $2}' | head -n 1
}

function get_ip_for_nic() {
  # returns any IPv4 for nic
  local nic=$1
  get_cidr_for_nic $nic | cut -d '/' -f 1
}

function get_default_ip() {
  local nic=$(get_default_nic)
  get_ip_for_nic $nic
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

function run_service() {
  if [[ -n "$CONTRAIL_USER" &&  "$(id -u)" = '0' ]] ; then
    mkdir -p /var/log/contrail
    chown $CONTRAIL_USER /var/log/contrail
    chmod 755 /var/log/contrail

    mkdir -p /etc/contrail
    chown $CONTRAIL_USER /etc/contrail
    chmod 755 -R /etc/contrail

    exec gosu $CONTRAIL_USER "$@"
  else
    exec "$@"
  fi
}
