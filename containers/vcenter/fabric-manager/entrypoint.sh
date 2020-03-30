#!/bin/bash

source /common.sh

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-vcenter-fabric-manager/cvfm.conf << EOM
[DEFAULTS]
host_ip=$(get_listen_ip_for_node VCENTER_FABRIC_MANAGER)
http_server_ip=$(get_introspect_listen_ip_for_node VCENTER_FABRIC_MANAGER)

[VCENTER]
vc_host=$VCENTER_SERVER
vc_port=${VCENTER_PORT:-443}
vc_username=$VCENTER_USERNAME
vc_password=$VCENTER_PASSWORD
vc_preferred_api_versions=${VCENTER_API_VERSION:-vim.version.version10}
vc_datacenter=$VCENTER_DATACENTER

[VNC]
api_server_host=$CONFIG_NODES
api_server_port=$CONFIG_API_PORT
api_server_use_ssl=$SSL_ENABLE
api_server_insecure=$SSL_INSECURE
api_keyfile=$SERVER_KEYFILE
api_certfile=$SERVER_CERTFILE
api_cafile=$SERVER_CA_CERTFILE

$sandesh_client_config

[INTROSPECT]
collectors=$COLLECTOR_SERVERS
logging_level=$LOG_LEVEL
log_file=$CONTAINER_LOG_DIR/contrail-vcenter-fabric-manager.log

[ZOOKEEPER]
zookeeper_servers=$ZOOKEEPER_SERVERS

[RABBIT]
rabbit_hosts=$RABBITMQ_NODES
rabbit_port=$RABBITMQ_NODE_PORT
$rabbit_config
$kombu_ssl_config

EOM

if [[ $AUTH_MODE == "keystone" ]]; then
    cat >> /etc/contrail/contrail-vcenter-fabric-manager/cvfm.conf << EOM
[AUTH]
auth_user=${KEYSTONE_AUTH_ADMIN_USER:-''}
auth_password=${KEYSTONE_AUTH_ADMIN_PASSWORD:-''}
auth_tenant=${KEYSTONE_AUTH_ADMIN_TENANT:-''}
auth_token_url=$KEYSTONE_AUTH_PROTO://${KEYSTONE_AUTH_HOST}:${KEYSTONE_AUTH_ADMIN_PORT}${KEYSTONE_AUTH_URL_TOKENS}
EOM
fi

run_service "$@"
