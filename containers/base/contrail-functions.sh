#!/bin/bash

function set_ctl() {
  local var=$1
  local value=$2
  local filename=`echo $var | sed "s/[^a-zA-Z0-9_.]/_/g" | cut -c1-50`
  local file=/etc/sysctl.d/60-$filename.conf
  local tmpfile=`mktemp -p /etc/sysctl.d/`
  echo "$var=$value" > $tmpfile
  mv $tmpfile $file
  sysctl -w ${var}=${value}
}

function is_ssl_enabled() {
  is_enabled "$SSL_ENABLE" \
   || is_enabled "$XMPP_SSL_ENABLE" \
   || is_enabled "$INTROSPECT_SSL_ENABLE" \
   || is_enabled "$SANDESH_SSL_ENABLE"
}

function wait_cmd_success() {
  local cmd=$1
  local interval=${2:-3}
  local max=${3:-20}
  local i=0
  while ! $cmd 2>/dev/null; do
      printf "."
      i=$((i + 1))
      if (( i > max )) ; then
        return 1
      fi
      sleep $interval
  done
  return 0
}

function wait_files() {
  local file1=$1
  local file2=$2
  printf "INFO: wait for files $file1 and $file2"
  wait_cmd_success "test -f $file1" || { echo -e "\nERROR: failed to wait $file1" && return 1; }
  wait_cmd_success "test -f $file2" || { echo -e "\nERROR: failed to wait $file2" && return 1; }
  echo -e "\nINFO: files $file1 and $file2 are present"
}

function wait_certs_if_ssl_enabled() {
  if ! is_ssl_enabled ; then
    return
  fi

  is_enabled $SSL_ENABLE && wait_files "$SERVER_KEYFILE" "$SERVER_CERTFILE"
  if [[ "$SERVER_KEYFILE" != "$XMPP_SERVER_KEYFILE" ]] ; then
    is_enabled $XMPP_SSL_ENABLE && wait_files "$XMPP_SERVER_CERTFILE" "$XMPP_SERVER_KEYFILE"
  fi
  if [[ "$SERVER_KEYFILE" != "$INTROSPECT_KEYFILE" ]] ; then
    is_enabled $INTROSPECT_SSL_ENABLE && wait_files "$INTROSPECT_CERTFILE" "$INTROSPECT_KEYFILE"
  fi
  if [[ "$SERVER_KEYFILE" != "$SANDESH_KEYFILE" ]] ; then
    is_enabled $SANDESH_SSL_ENABLE && wait_files "$SANDESH_CERTFILE" "$SANDESH_KEYFILE"
  fi
}

function wait_redis_certs_if_ssl_enabled() {
  if ! is_enabled ${REDIS_SSL_ENABLE} ; then
    return
  fi

  if [[ "$SERVER_KEYFILE" != "$REDIS_SSL_KEYFILE" ]]; then
    wait_files "$REDIS_SSL_CERTFILE" "$REDIS_SSL_KEYFILE"
  fi
}

function wait_config_api_certs_if_ssl_enabled() {
  if ! is_enabled ${CONFIG_API_SSL_ENABLE} ; then
    return
  fi

  if [[ "$SERVER_KEYFILE" != "$CONFIG_API_SERVER_KEYFILE" ]] ; then
    wait_files "$CONFIG_API_SERVER_CERTFILE" "$CONFIG_API_SERVER_KEYFILE"
  fi
}

function wait_analytics_api_certs_if_ssl_enabled() {
  if ! is_enabled ${ANALYTICS_API_SSL_ENABLE} ; then
    return
  fi

  if [[ "$SERVER_KEYFILE" != "$ANALYTICS_API_SERVER_KEYFILE" ]] ; then
    wait_files "$ANALYTICS_API_SERVER_CERTFILE" "$ANALYTICS_API_SERVER_KEYFILE"
  fi
}

function pre_start_init() {
  wait_certs_if_ssl_enabled
}

function is_tsn() {
  [[ -n "$TSN_AGENT_MODE" ]]
}

function is_dpdk() {
   test "$AGENT_MODE" == 'dpdk'
}

function is_sriov() {
   [[ -n "$SRIOV_PHYSICAL_INTERFACE" ]] && [[ "$SRIOV_VF" -ne 0 ]]
}

function set_third_party_auth_config(){
  if [[ $AUTH_MODE != "keystone" ]]; then
    return
  fi

  local tmp_file=/etc/contrail/contrail-keystone-auth.conf.tmp
  cat > $tmp_file << EOM
[KEYSTONE]
#memcache_servers=127.0.0.1:11211
admin_password = $KEYSTONE_AUTH_ADMIN_PASSWORD
admin_tenant_name = $KEYSTONE_AUTH_ADMIN_TENANT
admin_user = $KEYSTONE_AUTH_ADMIN_USER
auth_host = $KEYSTONE_AUTH_HOST
auth_port = $KEYSTONE_AUTH_ADMIN_PORT
auth_protocol = $KEYSTONE_AUTH_PROTO
auth_url = $KEYSTONE_AUTH_PROTO://${KEYSTONE_AUTH_HOST}:${KEYSTONE_AUTH_ADMIN_PORT}${KEYSTONE_AUTH_URL_VERSION}
auth_type = password
region_name = $KEYSTONE_AUTH_REGION_NAME
EOM
  if [[ "$KEYSTONE_AUTH_URL_VERSION" == '/v3' ]] ; then
    cat >> $tmp_file << EOM
user_domain_name = $KEYSTONE_AUTH_USER_DOMAIN_NAME
project_domain_name = $KEYSTONE_AUTH_PROJECT_DOMAIN_NAME
EOM
  fi
  if [[ "$KEYSTONE_AUTH_PROTO" == 'https' ]] ; then
    cat >> $tmp_file << EOM
insecure = ${KEYSTONE_AUTH_INSECURE,,}
certfile = $KEYSTONE_AUTH_CERTFILE
keyfile = $KEYSTONE_AUTH_KEYFILE
cafile = $KEYSTONE_AUTH_CA_CERTFILE
EOM
  fi
  if [[ -n "$KEYSTONE_AUTH_ENDPOINT_TYPE" ]] ; then
    echo "endpoint_type = $KEYSTONE_AUTH_ENDPOINT_TYPE" >> $tmp_file
  fi
  if [[ -n "$KEYSTONE_AUTH_SYNC_ON_DEMAND" ]] ; then
    echo "keystone_sync_on_demand = $KEYSTONE_AUTH_SYNC_ON_DEMAND" >> $tmp_file
  fi
  mv $tmp_file /etc/contrail/contrail-keystone-auth.conf
}

function set_vnc_api_lib_ini(){
  local tmp_file=/etc/contrail/vnc_api_lib.ini.tmp
  cat > $tmp_file << EOM
[global]
WEB_SERVER = $CONFIG_NODES
WEB_PORT = ${CONFIG_API_PORT:-8082}
BASE_URL = /
use_ssl = $CONFIG_API_SSL_ENABLE
EOM
  if is_enabled ${CONFIG_API_SSL_ENABLE}; then
    cat >> $tmp_file << EOM
cafile = $CONFIG_API_SERVER_CA_CERTFILE
EOM
  fi

  if [[ $AUTH_MODE == "keystone" ]]; then
    cat >> $tmp_file << EOM

; Authentication settings (optional)
[auth]
AUTHN_TYPE = keystone
AUTHN_PROTOCOL = $KEYSTONE_AUTH_PROTO
AUTHN_SERVER = $KEYSTONE_AUTH_HOST
AUTHN_PORT = $KEYSTONE_AUTH_ADMIN_PORT
AUTHN_URL = $KEYSTONE_AUTH_URL_TOKENS
AUTHN_DOMAIN = $KEYSTONE_AUTH_PROJECT_DOMAIN_NAME
;AUTHN_TOKEN_URL = http://127.0.0.1:35357/v2.0/tokens
EOM
    if [[ "$KEYSTONE_AUTH_PROTO" == 'https' ]] ; then
        cat >> $tmp_file << EOM
insecure = ${KEYSTONE_AUTH_INSECURE,,}
certfile = $KEYSTONE_AUTH_CERTFILE
keyfile = $KEYSTONE_AUTH_KEYFILE
cafile = $KEYSTONE_AUTH_CA_CERTFILE
EOM
    fi
  else
    cat >> $tmp_file << EOM
[auth]
AUTHN_TYPE = noauth
EOM
  fi
  mv $tmp_file /etc/contrail/vnc_api_lib.ini
}

function add_ini_params_from_env() {
  local service_name=$1
  local cfg_path=$2
  local delim='__'
  local vars=`( set -o posix ; set ) | grep "^${service_name}${delim}.*${delim}.*=.*$" | sort | cut -d '=' -f 1  | sed "s/^${service_name}${delim}//g"`
  local section=''
  for var in $vars ; do
    local var_name="${service_name}${delim}${var}"
    local val="${!var_name}"
    # variables in shell doesn't allow to use dashes in names but some sections/keys have them
    # substitute word 'DASH' to real dash here
    local var_unsubst=`echo $var | sed "s/DASH/-/g"`
    local var_section=`echo $var_unsubst | sed "s/^\(.*\)$delim.*$/\1/"`
    if [[ "$section" != "$var_section" ]]; then
      echo "[$var_section]" >> $cfg_path
      section="$var_section"
    fi
    local var_param=`echo $var_unsubst | sed "s/.*$delim\(.*\)$/\1/"`
    echo "$var_param = $val" >> $cfg_path
  done
}

function resolve_host_ip() {
  local name_or_ip=$1
  python3 -c "import socket; print(socket.gethostbyname('$name_or_ip'))"
}

function resolve_1st_control_node_ip() {
  local first_item=$(echo $CONTROL_NODES | cut -d ',' -f 1)
  resolve_host_ip $first_item
}

function get_iface_for_vrouter_from_control() {
  local node_ip=`echo $VROUTER_GATEWAY`
  if [[ -z "$node_ip" ]] ; then
    node_ip=$(resolve_1st_control_node_ip)
  fi
  local iface=$(get_gateway_nic_for_ip $node_ip)
  echo $iface
}

function get_ip_for_vrouter_from_control() {
  local iface=$(get_iface_for_vrouter_from_control)
  get_ip_for_nic $iface
}

function get_vrouter_physical_iface() {
  local iface=$PHYSICAL_INTERFACE
  if [[ -z "$iface" ]]; then
    iface=$(get_iface_for_vrouter_from_control)
    if [[ -z "$iface" ]] ; then
      iface=$(get_default_nic)
    fi
  fi
  echo $iface
}

function nic_has_ip() {
  test -n "$(get_cidr_for_nic $1)"
}

function wait_nic_up() {
  local nic=$1
  printf "INFO: wait for $nic is up"
  wait_cmd_success "nic_has_ip $nic" || { echo -e "\nERROR: $nic is not up" && return 1; }
  echo -e "\nINFO: $nic is up"
}
