#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-api.conf << EOM
[DEFAULTS]
listen_ip_addr=${CONFIG_API_LISTEN_ADDRESS:-0.0.0.0}
listen_port=${CONFIG_API_LISTEN_PORT:-$CONFIG_API_PORT}
http_server_port=${CONFIG_API_INTROSPECT_LISTEN_PORT:-$CONFIG_API_INTROSPECT_PORT}
log_file=${CONFIG_API_LOG_FILE:-"$LOG_DIR/contrail-api.log"}
log_level=${CONFIG_API_LOG_LEVEL:-$LOG_LEVEL}
list_optimization_enabled=${CONFIG_API_LIST_OPTIMIZATION_ENABLED:-True}
auth=${CONFIG_API_AUTH:-""}
aaa_mode=${CONFIG_API_AAA_MODE:-no-auth}
cassandra_server_list=$CONFIGDB_SERVERS
zk_server_ip=$ZOOKEEPER_SERVERS
rabbit_server=$RABBITMQ_SERVERS
rabbit_vhost=$RABBITMQ_VHOST
rabbit_user=$RABBITMQ_USER
rabbit_password=$RABBITMQ_PASSWORD
redis_server=$REDIS_SERVER_IP
collectors=$COLLECTOR_SERVERS

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
