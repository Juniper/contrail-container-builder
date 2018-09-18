#!/bin/bash

function set_ctl() {
    local var=$1
    local value=$2
    if grep -q "^$var" /etc/sysctl.conf ; then
        sed -i "s/^$var.*=.*/$var=$value/g"  /etc/sysctl.conf
    else
        echo "$var=$value" >> /etc/sysctl.conf
    fi
    sysctl -w ${var}=${value}
}

function is_ssl_enabled() {
  is_enabled "$SSL_ENABLE" \
   || is_enabled "$XMPP_SSL_ENABLE" \
   || is_enabled "$INTROSPECT_SSL_ENABLE" \
   || is_enabled "$SANDESH_SSL_ENABLE"
}

function wait_files() {
  local file1=$1
  local file2=$2
  local count=0
  while (true) ; do
    if [[ -f "$file1" && -f "$file2" ]] ; then
      return
    fi
    (( count+=1 ))
    if (( count == 60 ))  ; then
      break
    fi
    sleep 1
  done
  return 1
}

function wait_certs_if_ssl_enabled() {
  if ! is_ssl_enabled ; then
    return
  fi

  is_enabled $SSL_ENABLE && wait_files "$SERVER_KEYFILE" "$SERVER_CERTFILE"
  if [[ "$SERVER_KEYFILE" != "$XMPP_SERVER_CERTFILE" ]] ; then
    is_enabled $XMPP_SSL_ENABLE && wait_files "$XMPP_SERVER_CERTFILE" "$XMPP_SERVER_KEYFILE"
  fi
  if [[ "$SERVER_KEYFILE" != "$INTROSPECT_CERTFILE" ]] ; then
    is_enabled $INTROSPECT_SSL_ENABLE && wait_files "$INTROSPECT_CERTFILE" "$INTROSPECT_KEYFILE"
  fi
  if [[ "$SERVER_KEYFILE" != "$SANDESH_CERTFILE" ]] ; then
    is_enabled $SANDESH_SSL_ENABLE && wait_files "$SANDESH_CERTFILE" "$SANDESH_KEYFILE"
  fi
}

function pre_start_init() {
  wait_certs_if_ssl_enabled
}

function is_tsn() {
  [[ $TSN_EVPN_MODE =~ ^[Tt][Rr][Uu][Ee]$ ]]
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
EOM
  if [[ "$KEYSTONE_AUTH_URL_VERSION" == '/v3' ]] ; then
    cat >> $tmp_file << EOM
user_domain_name = $KEYSTONE_AUTH_USER_DOMAIN_NAME
project_domain_name = $KEYSTONE_AUTH_PROJECT_DOMAIN_NAME
region_name = $KEYSTONE_AUTH_REGION_NAME
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
  mv $tmp_file /etc/contrail/contrail-keystone-auth.conf
}

function set_vnc_api_lib_ini(){
  local tmp_file=/etc/contrail/vnc_api_lib.ini.tmp
  cat > $tmp_file << EOM
[global]
WEB_SERVER = $CONFIG_NODES
WEB_PORT = ${CONFIG_API_PORT:-8082}
BASE_URL = /
EOM

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
    local var_section=`echo $var | sed "s/^\(.*\)$delim.*$/\1/"`
    if [[ "$section" != "$var_section" ]]; then
      echo "[$var_section]" >> $cfg_path
      section="$var_section"
    fi
    local var_param=`echo $var | sed "s/.*$delim\(.*\)$/\1/"`
    echo "$var_param = $val" >> $cfg_path
  done
}

function get_vrouter_physical_iface() {
  local iface=$PHYSICAL_INTERFACE
  if [[ -z "$iface" ]]; then
    iface=$(get_iface_for_vrouter_from_control)
    if [[ -z "$iface" ]] ; then
      iface=$DEFAULT_IFACE
    fi
  fi
  echo $iface
}

function create_lbaas_auth_conf() {
    read -r -d '' openstack_lbaas_auth << EOM || true
[BARBICAN]
admin_tenant_name = service
admin_user = ${BARBICAN_USER}
admin_password = ${BARBICAN_PASSWORD}
auth_url = $KEYSTONE_AUTH_PROTO://${KEYSTONE_AUTH_HOST}:${KEYSTONE_AUTH_ADMIN_PORT}${KEYSTONE_AUTH_URL_VERSION}
region = $KEYSTONE_AUTH_REGION_NAME
user_domain_name = $KEYSTONE_AUTH_USER_DOMAIN_NAME
project_domain_name = $KEYSTONE_AUTH_PROJECT_DOMAIN_NAME
region_name = $KEYSTONE_AUTH_REGION_NAME
insecure = ${KEYSTONE_AUTH_INSECURE}
certfile = $KEYSTONE_AUTH_CERTFILE
keyfile = $KEYSTONE_AUTH_KEYFILE
cafile = $KEYSTONE_AUTH_CA_CERTFILE
EOM
    read -r -d '' kubernetes_lbaas_auth << EOM || true
[KUBERNETES]
kubernetes_token=$K8S_TOKEN
kubernetes_api_server=${KUBERNETES_API_SERVER:-${DEFAULT_LOCAL_IP}}
kubernetes_api_port=${KUBERNETES_API_PORT:-8080}
kubernetes_api_secure_port=${KUBERNETES_API_SECURE_PORT:-6443}
EOM
    echo "INFO: Preparing /etc/contrail/contrail-lbaas-auth.conf"
    cat << EOM > /etc/contrail/contrail-lbaas-auth.conf
$openstack_lbaas_auth
$kubernetes_lbaas_auth
EOM
}
