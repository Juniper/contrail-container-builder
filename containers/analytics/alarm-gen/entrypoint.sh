#!/bin/bash

source /common.sh

host_ip=$(get_listen_ip_for_node ANALYTICS)
config_db_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-alarm-gen.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
partitions=${ALARMGEN_partitions:-30}
http_server_port=${ALARMGEN_INTROSPECT_LISTEN_PORT:-$ALARMGEN_INTROSPECT_PORT}
log_file=${ALARMGEN_LOG_FILE:-"$LOG_DIR/contrail-alarm-gen.log"}
log_level=${ALARMGEN_LOG_LEVEL:-$LOG_LEVEL}
#log_category =
log_local=${ALARMGEN_LOG_LOCAL:-$LOG_LOCAL}
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
rabbitmq_server_list=$RABBITMQ_NODES
rabbitmq_port=$RABBITMQ_NODE_PORT
rabbitmq_vhost=$RABBITMQ_VHOST
rabbitmq_user=$RABBITMQ_USER
rabbitmq_password=$RABBITMQ_PASSWORD
rabbitmq_use_ssl=$RABBITMQ_USE_SSL
config_db_server_list=$config_db_server_list

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
