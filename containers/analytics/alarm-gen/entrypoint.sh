#!/bin/bash

source /common.sh

host_ip=$(get_listen_ip_for_node ANALYTICS)
config_db_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-alarm-gen.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
partitions=${ALARMGEN_partitions:-30}
http_server_port=${ALARMGEN_INTROSPECT_LISTEN_PORT:-$ALARMGEN_INTROSPECT_PORT}
log_file="$LOG_DIR/contrail-alarm-gen.log"
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
collectors=$COLLECTOR_SERVERS
kafka_broker_list=$KAFKA_SERVERS
zk_list=$ZOOKEEPER_ANALYTICS_SERVERS_SPACE_DELIM

[API_SERVER]
# List of api-servers in ip:port format separated by space
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_USE_SSL:-False}

[REDIS]
redis_server_port=$REDIS_SERVER_PORT
redis_uve_list=$REDIS_SERVERS

[CONFIGDB]
config_db_server_list=$config_db_server_list

rabbitmq_server_list=$RABBITMQ_NODES
$rabbitmq_auth_config

$sandesh_client_config
EOM

add_ini_params_from_env ALARM_GEN /etc/contrail/contrail-alarm-gen.conf

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
