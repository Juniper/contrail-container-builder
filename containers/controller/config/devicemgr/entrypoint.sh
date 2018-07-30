#!/bin/bash

source /common.sh

pre_start_init

cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-device-manager.conf << EOM
[DEFAULTS]
api_server_ip=$CONFIG_NODES
api_server_port=$CONFIG_API_PORT
analytics_server_ip=$ANALYTICS_NODES
analytics_server_port=$ANALYTICS_API_PORT
push_mode=1
log_file=$LOG_DIR/contrail-device-manager.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
cassandra_server_list=$cassandra_server_list
zk_server_ip=$ZOOKEEPER_SERVERS

rabbit_server=$RABBITMQ_SERVERS
$rabbit_config
$kombu_ssl_config

collectors=$COLLECTOR_SERVERS

$sandesh_client_config
EOM

add_ini_params_from_env DEVICE_MANAGER /etc/contrail/contrail-device-manager.conf

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
