#!/bin/bash

source /common.sh

pre_start_init

cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-schema.conf << EOM
[DEFAULTS]
api_server_ip=$CONFIG_NODES
api_server_port=$CONFIG_API_PORT
log_file=$LOG_DIR/contrail-schema.log
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
if [ $STATS_COLLECTOR_DESTINATION_PATH != '' ]; then
    cat >> /etc/contrail/contrail-schema.conf << EOM
[STATS]
stats_collector=${STATS_COLLECTOR_DESTINATION_PATH}
EOM
fi
add_ini_params_from_env SCHEMA /etc/contrail/contrail-schema.conf

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
