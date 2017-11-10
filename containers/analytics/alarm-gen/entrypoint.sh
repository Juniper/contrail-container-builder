#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-alarm-gen.conf << EOM
[DEFAULTS]
host_ip=${ALARMGEN_LISTEN_IP:-`get_listen_ip`}
partitions=${ALARMGEN_partitions:-30}
http_server_port=${ALARMGEN_INTROSPECT_LISTEN_PORT:-$ALARMGEN_INTROSPECT_PORT}
log_file=${ALARMGEN_LOG_FILE:-"$LOG_DIR/contrail-alarm-gen.log"}
log_level=${ALARMGEN_LOG_LEVEL:-$LOG_LEVEL}
#log_category = 
log_local=${ALARMGEN_LOG_LOCAL:-$LOG_LOCAL}
collectors=$COLLECTOR_SERVERS
kafka_broker_list=$KAFKA_SERVERS
zk_list=${ZOOKEEPER_SERVERS:-`get_server_list ZOOKEEPER ":$ZOOKEEPER_PORT "`}
rabbitmq_server_list=$RABBITMQ_NODES
rabbitmq_port=$RABBITMQ_PORT
rabbitmq_vhost=$RABBITMQ_VHOST
rabbitmq_user=$RABBITMQ_USER
rabbitmq_password=$RABBITMQ_PASSWORD
rabbitmq_use_ssl=$RABBITMQ_USE_SSL

[API_SERVER]
# List of api-servers in ip:port format separated by space
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_USE_SSL:-False}

[REDIS]
#redis_server_port=${ALARM_GEN_redis_server_port:-6379}
redis_uve_list=$REDIS_SERVERS

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
