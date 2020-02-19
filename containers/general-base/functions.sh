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
  if [ -n "$extended_server_list" ] ; then
    echo "${extended_server_list::-1}"
  fi
}

function get_default_hostname() {
  hostname -f
}

function get_gateway_nic_for_ip() {
  if ! command -v ip > /dev/null ; then
    echo 'lo'
    return
  fi
  local ip=$1
  local iface=$(ip route get $ip | grep -o "dev.*" | awk '{print $2}')
  if [[ "$iface" == 'lo' ]] ; then
    # ip is belong to this machine
    # Workaround for the case of Openshift with single NIC
    # on compute node (that is used for vhost0 in kernel mode):
    # dhclient may be still running and get an IP for the initial NIC
    # https://contrail-jws.atlassian.net/browse/JCB-219329
    iface=$(ip address show | grep -F "inet ${ip}/" | awk '{print($NF)}' | grep -m 1 vhost0)
    [ -z "$iface" ] && iface=$(ip address show | grep -m 1 -F "inet ${ip}/" | awk '{print($NF)}')
  fi
  echo $iface
}

function get_default_nic() {
  get_gateway_nic_for_ip 1
}

function get_cidr_for_nic() {
  if ! command -v ip > /dev/null ; then
    echo '127.0.0.1/8'
    return
  fi
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
      server_ip=`python3 -c "import socket; print(socket.gethostbyname('$server'))"` || ret=$?
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


function do_run_service() {
  if [[ -n "$CONTRAIL_UID" && -n "$CONTRAIL_GID" &&  "$(id -u)" = '0' ]] ; then
    # processes are run under root and contrail users
    # so, contrail user has to has rights to right there for
    # core generation
    mkdir -p /var/crashes
    chmod 777 /var/crashes

    local user_name=$(id -un $CONTRAIL_UID)
    export HOME=/home/$user_name
    mkdir -p $HOME
    chown -R $CONTRAIL_UID:$CONTRAIL_GID $HOME
    exec setpriv --reuid $CONTRAIL_UID --regid $CONTRAIL_GID --clear-groups --no-new-privs "$@"
  else
    exec "$@"
  fi
}

function run_service() {
  if [[ -n "$CONTRAIL_UID" && -n "$CONTRAIL_GID" &&  "$(id -u)" = '0' ]] ; then
    local owner_opts="$CONTRAIL_UID:$CONTRAIL_GID"
    
    mkdir -p $LOG_DIR
    # change files only with root
    #   in some cases rabbit, redis and other services
    #   may keep logs there under their users
    chown $owner_opts $LOG_DIR
    find $LOG_DIR -uid 0 -exec chown $owner_opts {} + ;
    # some orchetrators configure other services to log into this dif, e.g. rabbit
    # that are run under their users.
    chmod 770 $LOG_DIR

    mkdir -p /etc/contrail
    chown $owner_opts /etc/contrail
    find /etc/contrail -uid 0 -exec chown $owner_opts {} + ;
    chmod 755 /etc/contrail
  fi
  do_run_service "$@"
}
