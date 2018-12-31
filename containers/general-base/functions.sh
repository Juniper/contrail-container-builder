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

function get_routes() {
  local opt=''
  if awk --help | grep "non-decimal-data" ; then
    # new versions of awk requires to specify this option to be able to convert hex to dec
    opt='--non-decimal-data'
  fi
  awk $opt 'NR==1{for(i=1;i<=NF;i++){if($i=="Iface"){col1=i};if($i=="Destination"){col2=i};if($i=="Mask"){col3=i};if($i=="Metric"){col4=i}}} NR>1{gsub(/../,"0x& ",$col2);gsub(/../,"& ",$col3);FS=" ";split($col2,a);split($col3,b);mask=int(sprintf("0x%s%s%s%s", b[4], b[3], b[2], b[1])); bits=0;while(mask){bits+=(mask%2);mask=int(mask/2)};  printf("%s %d.%d.%d.%d/%d %s\n", $col1, a[4], a[3], a[2], a[1], bits, $col4)}' /proc/net/route
}

function get_default_nic() {
  get_routes | awk '/0.0.0.0\/0/{print $1}'
}

function get_nic_cidrs() {
  # returns all 
  local nic=$1
  get_routes | awk -v nic=$nic '{if($1==nic && $2!="0.0.0.0/0"){print($2)}}'
}

function get_cidr_for_nic() {
  local nic=$1
  local cidrs=`get_nic_cidrs $nic`
  local cidr=''
  for cidr in $cidrs ; do
    local ip=`awk -v cidr="$cidr" -v flag="0" '{if($2 == cidr){flag=1}; if(flag==1 && $1=="/32" && $2=="host"){print f;flag=0} {f=$2}}' /proc/net/fib_trie | head -1`
    if [[ -n "$ip" ]]; then
      echo "$ip/$(echo $cidr | cut -d '/' -f 2)"
      return
    fi
  done
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
