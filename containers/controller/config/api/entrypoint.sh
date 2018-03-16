#!/bin/bash

source /common.sh

host_ip=$(get_listen_ip_for_node CONFIG)
cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-api.conf << EOM
[DEFAULTS]
listen_ip_addr=${host_ip}
listen_port=$CONFIG_API_PORT
http_server_port=${CONFIG_API_INTROSPECT_PORT}
log_file=${CONFIG_API_LOG_FILE:-"$LOG_DIR/contrail-api.log"}
log_level=${CONFIG_API_LOG_LEVEL:-$LOG_LEVEL}
list_optimization_enabled=${CONFIG_API_LIST_OPTIMIZATION_ENABLED:-True}
auth=$AUTH_MODE
aaa_mode=$AAA_MODE
cloud_admin_role=$CLOUD_ADMIN_ROLE
global_read_only_role=$GLOBAL_READ_ONLY_ROLE
cassandra_server_list=$cassandra_server_list
zk_server_ip=$ZOOKEEPER_SERVERS

rabbit_server=$RABBITMQ_SERVERS
$rabbit_config
$kombu_ssl_config

redis_server=$REDIS_SERVER_IP
collectors=$COLLECTOR_SERVERS

$sandesh_client_config
EOM

add_ini_params_from_env API /etc/contrail/contrail-api.conf

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
