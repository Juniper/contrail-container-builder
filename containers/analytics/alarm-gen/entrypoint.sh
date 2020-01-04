#!/bin/bash

source /common.sh
export ALARMGEN_REDIS_AGGREGATE_DB_OFFSET=${ALARMGEN_REDIS_AGGREGATE_DB_OFFSET:-`get_order_for_node ANALYTICS`}

pre_start_init
wait_redis_certs_if_ssl_enabled

host_ip=$(get_listen_ip_for_node ANALYTICS_ALARM)
config_db_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-alarm-gen.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
partitions=${ALARMGEN_partitions:-30}
http_server_ip=$(get_introspect_listen_ip_for_node ANALYTICS_ALARM)
http_server_port=${ALARMGEN_INTROSPECT_LISTEN_PORT:-$ALARMGEN_INTROSPECT_PORT}
log_file=$LOG_DIR/contrail-alarm-gen.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
collectors=$COLLECTOR_SERVERS
zk_list=$ZOOKEEPER_SERVERS_SPACE_DELIM

[API_SERVER]
# List of api-servers in ip:port format separated by space
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_SSL_ENABLE}

[REDIS]
redis_server_port=$REDIS_SERVER_PORT
redis_uve_list=$REDIS_SERVERS
redis_password=$REDIS_SERVER_PASSWORD
redis_use_ssl=$REDIS_SSL_ENABLE
${redis_ssl_config}

[KAFKA]
kafka_broker_list=$KAFKA_SERVERS
kafka_ssl_enable=$KAFKA_SSL_ENABLE
${kafka_ssl_config}

[CONFIGDB]
config_db_server_list=$config_db_server_list
config_db_use_ssl=${CASSANDRA_SSL_ENABLE,,}
config_db_ca_certs=$CASSANDRA_SSL_CA_CERTFILE

rabbitmq_server_list=$RABBITMQ_SERVERS
$rabbitmq_config
$kombu_ssl_config

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env ALARM_GEN /etc/contrail/contrail-alarm-gen.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
