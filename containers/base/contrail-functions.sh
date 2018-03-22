#!/bin/bash

function pre_start_init() {
   # this file has to be applied manually in containers
   sysctl -p /etc/sysctl.d/10-core-pattern.conf
}

function is_tsn() {
    [[ $TSN_EVPN_MODE =~ ^[Tt][Rr][Uu][Ee]$ ]]
}

function is_dpdk() {
    test "$AGENT_MODE" == 'dpdk'
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
auth_url = $KEYSTONE_AUTH_PROTO://${KEYSTONE_AUTH_HOST}:${KEYSTONE_AUTH_ADMIN_PORT}${KEYSTONE_AUTH_URL_VERSION}
auth_type = password
EOM
    if [[ "$KEYSTONE_AUTH_URL_VERSION" == '/v3' ]] ; then
      cat >> /etc/contrail/contrail-keystone-auth.conf << EOM
user_domain_name = $KEYSTONE_AUTH_USER_DOMAIN_NAME
project_domain_name = $KEYSTONE_AUTH_PROJECT_DOMAIN_NAME
region_name = $KEYSTONE_AUTH_REGION_NAME
EOM
    fi
    if [[ "$KEYSTONE_AUTH_PROTO" == 'https' ]] ; then
      cat >> /etc/contrail/contrail-keystone-auth.conf << EOM
insecure = ${KEYSTONE_AUTH_INSECURE,,}
certfile = $KEYSTONE_AUTH_CERTFILE
keyfile = $KEYSTONE_AUTH_KEYFILE
cafile = $KEYSTONE_AUTH_CA_CERTFILE
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
    if [[ "$KEYSTONE_AUTH_PROTO" == 'https' ]] ; then
        cat >> /etc/contrail/vnc_api_lib.ini << EOM
insecure = ${KEYSTONE_AUTH_INSECURE,,}
certfile = $KEYSTONE_AUTH_CERTFILE
keyfile = $KEYSTONE_AUTH_KEYFILE
cafile = $KEYSTONE_AUTH_CA_CERTFILE
EOM
    fi
  else
    cat >> /etc/contrail/vnc_api_lib.ini << EOM
[auth]
AUTHN_TYPE = noauth
EOM
  fi
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
    local var_section=`echo $var | sed "s/^\(.*\)$delim.*$/\1/"`
    if [[ "$section" != "$var_section" ]]; then
      echo "[$var_section]" >> $cfg_path
      section="$var_section"
    fi
    local var_param=`echo $var | sed "s/.*$delim\(.*\)$/\1/"`
    echo "$var_param = $val" >> $cfg_path
  done
}

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
