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

function get_iface_for_vrouter_from_control() {
  local node_ip=`echo $CONTROL_NODES | cut -d ',' -f 1`
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

#START: These functions below are "inspired" from https://dalemonk.wordpress.com/network-scripts/
function cidr_to_subnet_mask() {
    local i
    local subnetmask=""
    local full_octets=$(($1/8))
    local partial_octet=$(($1%8))
    for ((i=0;i<4;i+=1)); do
        if [ $i -lt $full_octets ]; then
            subnetmask+=255
        elif [ $i -eq $full_octets ]; then
            subnetmask+=$((256 - 2**(8-$partial_octet)))
        else
            subnetmask+=0
        fi
        [ $i -lt 3 ] && subnetmask+=.
    done
    echo $subnetmask
}

function ip_to_octets()
{
    local ip_address=$(echo $1 | awk -F/ {'print $1'})
    OLDIFS="$IFS"
    IFS=.
    set $ip_address
    local octet1=$1
    local octet2=$2
    local octet3=$3
    local octet4=$4
    IFS="$OLDIFS"
    echo $octet1 $octet2 $octet3 $octet4
}

# Returns the 'subnet/mask' of an interface given its 'ip/mask'
function get_subnet_addr() {
   local ip_address="$1"
   local cidr=$(echo $ip_address | awk -F/ {'print $2'})
   local subnetmask=$(cidr_to_subnet_mask $cidr)
   local octetip=$(ip_to_octets $ip_address)
   local octetsn=$(ip_to_octets $subnetmask)

   local octetip1=$(echo $octetip | awk {'print $1'})
   local octetip2=$(echo $octetip | awk {'print $2'})
   local octetip3=$(echo $octetip | awk {'print $3'})
   local octetip4=$(echo $octetip | awk {'print $4'})

   local octetsn1=$(echo $octetsn | awk {'print $1'})
   local octetsn2=$(echo $octetsn | awk {'print $2'})
   local octetsn3=$(echo $octetsn | awk {'print $3'})
   local octetsn4=$(echo $octetsn | awk {'print $4'})

   local netaddress=$(($octetip1 & $octetsn1)).$(($octetip2 & $octetsn2)).$(($octetip3 & $octetsn3)).$(($octetip4 & $octetsn4))
   echo $netaddress
}

#END: These functions above are "inspired" from https://dalemonk.wordpress.com/network-scripts/

function get_cidr_subnet_for_nic() {
  local nic=$1
  local if_cidr=$(get_cidr_for_nic $nic)
  local if_cidr_subnet=$(get_subnet_addr $if_cidr)
  echo $if_cidr_subnet
}

