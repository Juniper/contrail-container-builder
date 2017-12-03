#!/bin/bash

function wait_for_contrail_api() {
  local config_node_list=''
  IFS=',' read -ra config_node_list <<< "${CONFIG_NODES}"
  echo "INFO $(date): waiting for API servers: ${config_node_list[@]}"
  local port=$CONFIG_API_PORT
  local count=0
  for n in ${config_node_list[@]} ; do
    for (( i=0; i<120; i++)) ; do
      echo "INFO $(date): waiting for API server $n: $i / 120"
      sleep 3
      if curl -sI http://${n}:${port}/ | head -1 | grep -q 200 ; then
        echo "INFO $(date): API server $n is ready."
        (( count+=1 ))
        break
      fi
    done
  done
  if (( count == 0 )) ; then
    echo "ERROR $(date): Config API servers  ${config_node_list[@]}  are not responding on port ${port}. Exiting..."
  fi
  if (( count != ${#config_node_list[@]} )) ; then
    echo "WARNING $(date): Some of Config API servers  ${config_node_list[@]}  are not responding on port ${port}."
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
  local extended_list="${extended_server_list::-1}"
  echo ${extended_list}
}

function set_third_party_auth_config(){
  if [[ $AUTH_MODE == "keystone" ]]; then
    cat > /etc/contrail/contrail-keystone-auth.conf << EOM
[KEYSTONE]
#memcache_servers=127.0.0.1:11211
admin_password = $KEYSTONE_AUTH_ADMIN_PASSWORD
admin_tenant_name = $KEYSTONE_AUTH_ADMIN_TENANT
admin_user = $KEYSTONE_AUTH_ADMIN_USER
auth_host = $KEYSTONE_AUTH_HOST
auth_port = $KEYSTONE_AUTH_ADMIN_PORT
auth_protocol = $KEYSTONE_AUTH_PROTO
insecure = false
auth_url = $KEYSTONE_AUTH_PROTO://${KEYSTONE_AUTH_HOST}:${KEYSTONE_AUTH_ADMIN_PORT}${KEYSTONE_AUTH_URL_VERSION}
auth_type = password
EOM
    if [[ "$KEYSTONE_AUTH_URL_VERSION" == '/v3' ]] ; then
      cat >> /etc/contrail/contrail-keystone-auth.conf << EOM
user_domain_name = $KEYSTONE_AUTH_USER_DOMAIN_NAME
project_domain_name = $KEYSTONE_AUTH_PROJECT_DOMAIN_NAME
EOM
    fi
  fi
}

function set_vnc_api_lib_ini(){
# TODO: set WEB_SERVER to VIP
  cat > /etc/contrail/vnc_api_lib.ini << EOM
[global]
WEB_SERVER = $CONFIG_NODES
WEB_PORT = ${CONFIG_API_PORT:-8082}
BASE_URL = /
EOM

  if [[ $AUTH_MODE == "keystone" ]]; then
    cat >> /etc/contrail/vnc_api_lib.ini << EOM

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
  else
    cat >> /etc/contrail/vnc_api_lib.ini << EOM
[auth]
AUTHN_TYPE = noauth
EOM
  fi
}

function get_default_nic() {
  ip route show | grep 'default via' | head -n 1 | awk '{print $5}'
}

function get_default_ip() {
  local default_interface=$(get_default_nic)
  ip address show dev $default_interface | head -3 | tail -1 | tr '/' ' ' | awk '{print $2}'
}

function get_default_gateway_for_nic() {
  local nic=$1
  ip route show dev $nic | grep default | awk '{print $3}'
}

function find_my_ip_for_node() {
  local server_typ=$1_NODES
  local server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  local local_ips=$(ip addr | awk '/inet/ {print($2)}')
  for server in "${server_list[@]}"; do
    if [[ "$local_ips" =~ "$server" ]] ; then
      echo $server
      return
    fi
  done
}

function get_vip_for_node() {
  local ip=$(find_my_ip_for_node $1)
  if [[ -z "$ip" ]] ; then
    local server_typ=$1_NODES
    ip=$(echo ${!server_typ} | cut -d',' -f 1)
  fi
  echo $ip
}

function get_listen_ip_for_node() {
  local ip=$(find_my_ip_for_node $1)
  if [[ -z "$ip" ]] ; then
    ip=$(get_default_ip)
  fi
  echo $ip
}

function provision() {
  local script=$1
  shift 1
  local rest_params="$@"
  local retries=${PROVISION_RETRIES:-10}
  local pause=${PROVISION_DELAY:-3}
  for (( i=0 ; i < retries ; ++i )) ; do
      echo "Provisioning: $script $rest_params: $i/$retries"
      if python /opt/contrail/utils/$script  \
              $rest_params \
              --api_server_ip $CONFIG_API_VIP \
              --api_server_port $CONFIG_API_PORT \
              $AUTH_PARAMS ; then
          echo "Provisioning: $script $rest_params: succeeded"
          break;
      fi
      sleep $pause
  done
}

function provision_node() {
  local script=$1
  local host_ip=$2
  local host_name=$3
  shift 3
  local rest_params="$@"
  provision $script --oper add --host_name $host_name --host_ip $host_ip $rest_params
}
