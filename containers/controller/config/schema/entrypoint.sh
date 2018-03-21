#!/bin/bash

source /common.sh

pre_start_init

cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-schema.conf << EOM
[DEFAULTS]
api_server_ip=$CONFIG_API_VIP
api_server_port=$CONFIG_API_PORT
log_file=$LOG_DIR/contrail-schema.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
cassandra_server_list=$cassandra_server_list
zk_server_ip=$ZOOKEEPER_SERVERS

rabbit_server=$RABBITMQ_SERVERS
$rabbit_config
$kombu_ssl_config

redis_server=$REDIS_SERVER_IP
collectors=$COLLECTOR_SERVERS

$sandesh_client_config
EOM

add_ini_params_from_env SCHEMA /etc/contrail/contrail-schema.conf

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
