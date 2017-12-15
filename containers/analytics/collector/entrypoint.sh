#!/bin/bash

source /common.sh

hostip=$(get_listen_ip_for_node ANALYTICS)
rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
configdb_cql_servers=$(echo $CONFIGDB_CQL_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-collector.conf << EOM
[DEFAULT]
analytics_data_ttl=${ANALYTICS_DATA_TTL:-48}
analytics_config_audit_ttl=${ANALYTICS_CONFIG_AUDIT_TTL:-2160}
analytics_statistics_ttl=${ANALYTICS_STATISTICS_TTL:-168}
analytics_flow_ttl=${ANALYTICS_FLOW_TTL:-2}
partitions=${ANALYTICS_UVE_PARTITIONS:-30}
hostip=${hostip}
hostname=${DEFAULT_HOSTNAME}
http_server_port=${COLLECTOR_INTROSPECT_LISTEN_PORT:-$COLLECTOR_INTROSPECT_PORT}
syslog_port=${COLLECTOR_SYSLOG_LISTEN_PORT:-$COLLECTOR_SYSLOG_PORT}
sflow_port=${COLLECTOR_SFLOW_LISTEN_PORT:-$COLLECTOR_SFLOW_PORT}
ipfix_port=${COLLECTOR_IPFIX_LISTEN_PORT:-$COLLECTOR_IPFIX_PORT}
# log_category=
log_file=${COLLECTOR_LOG_FILE:-"$LOG_DIR/contrail-collector.log"}
log_files_count=${COLLECTOR_LOG_FILE_COUNT:-10}
log_file_size=${COLLECTOR_LOG_FILE_SIZ:-1048576}
log_level=${COLLECTOR_LOG_LEVLE:-$LOG_LEVEL}
log_local=${COLLECTOR_LOG_LOCAL:-$LOG_LOCAL}
# sandesh_send_rate_limit=
cassandra_server_list=$ANALYTICSDB_CQL_SERVERS
kafka_broker_list=$KAFKA_SERVERS
zookeeper_server_list=$ZOOKEEPER_ANALYTICS_SERVERS

[COLLECTOR]
port=${COLLECTOR_LISTEN_PORT:-$COLLECTOR_PORT}
server=${COLLECTOR_SERVER_LISTEN_IP:-0.0.0.0}
protobuf_port=${COLLECTOR_PROTOBUF_LISTEN_PORT:-$COLLECTOR_PROTOBUF_PORT}

[STRUCTURED_SYSLOG_COLLECTOR]
# TCP & UDP port to listen on for receiving structured syslog messages
port=${COLLECTOR_STRUCTURED_SYSLOG_LISTEN_PORT:-$COLLECTOR_STRUCTURED_SYSLOG_PORT}
# List of external syslog receivers to forward structured syslog messages in ip:port format separated by space
# tcp_forward_destination=10.213.17.53:514
kafka_broker_list=$KAFKA_SERVERS
kafka_topic=${KAFKA_TOPIC:-structured_syslog_topic}
# number of kafka partitions
kafka_partitions=${KAFKA_PARTITIONS:-30}

[API_SERVER]
# List of api-servers in ip:port format separated by space
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_USE_SSL:-False}

[DATABASE]
# disk usage percentage
disk_usage_percentage.high_watermark0=${COLLECTOR_disk_usage_percentage_high_watermark0:-90}
disk_usage_percentage.low_watermark0=${COLLECTOR_disk_usage_percentage_low_watermark0:-85}
disk_usage_percentage.high_watermark1=${COLLECTOR_disk_usage_percentage_high_watermark1:-80}
disk_usage_percentage.low_watermark1=${COLLECTOR_disk_usage_percentage_low_watermark1:-75}
disk_usage_percentage.high_watermark2=${COLLECTOR_disk_usage_percentage_high_watermark2:-70}
disk_usage_percentage.low_watermark2=${COLLECTOR_disk_usage_percentage_low_watermark2:-60}

# Cassandra pending compaction tasks
pending_compaction_tasks.high_watermark0=${COLLECTOR_pending_compaction_tasks_high_watermark0:-400}
pending_compaction_tasks.low_watermark0=${COLLECTOR_pending_compaction_tasks_low_watermark0:-300}
pending_compaction_tasks.high_watermark1=${COLLECTOR_pending_compaction_tasks_high_watermark1:-200}
pending_compaction_tasks.low_watermark1=${COLLECTOR_pending_compaction_tasks_low_watermark1:-150}
pending_compaction_tasks.high_watermark2=${COLLECTOR_pending_compaction_tasks_high_watermark2:-100}
pending_compaction_tasks.low_watermark2=${COLLECTOR_pending_compaction_tasks_low_watermark2:-80}

# Message severity levels to be written to database
high_watermark0.message_severity_level=${COLLECTOR_high_watermark0_message_severity_level:-SYS_EMERG}
low_watermark0.message_severity_level=${COLLECTOR_low_watermark0_message_severity_level:-SYS_ALERT}
high_watermark1.message_severity_level=${COLLECTOR_high_watermark1_message_severity_level:-SYS_ERR}
low_watermark1.message_severity_level=${COLLECTOR_low_watermark1_message_severity_level:-SYS_WARN}
high_watermark2.message_severity_level=${COLLECTOR_high_watermark2_message_severity_level:-SYS_DEBUG}
low_watermark2.message_severity_level=${COLLECTOR_low_watermark2_message_severity_level:-INVALID}

[REDIS]
port=$REDIS_SERVER_PORT
server=$REDIS_SERVER_IP

[CONFIGDB]
rabbitmq_server_list=$rabbitmq_server_list
rabbitmq_vhost=$RABBITMQ_VHOST
rabbitmq_user=$RABBITMQ_USER
rabbitmq_password=$RABBITMQ_PASSWORD
rabbitmq_use_ssl=$RABBITMQ_USE_SSL
config_db_server_list=$configdb_cql_servers

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
