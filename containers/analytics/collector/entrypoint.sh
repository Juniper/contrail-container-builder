#!/bin/bash

source /common.sh

pre_start_init

hostip=$(get_listen_ip_for_node ANALYTICS)
hostname=$(resolve_hostname_by_ip $hostip)
rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
configdb_cql_servers=$(echo $CONFIGDB_CQL_SERVERS | sed 's/,/ /g')

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-collector.conf << EOM
[DEFAULT]
analytics_data_ttl=${ANALYTICS_DATA_TTL:-48}
analytics_config_audit_ttl=${ANALYTICS_CONFIG_AUDIT_TTL:-2160}
analytics_statistics_ttl=${ANALYTICS_STATISTICS_TTL:-168}
analytics_flow_ttl=${ANALYTICS_FLOW_TTL:-2}
partitions=${ANALYTICS_UVE_PARTITIONS:-30}
hostip=${hostip}
hostname=${hostname:-$(get_default_hostname)}
http_server_port=${COLLECTOR_INTROSPECT_LISTEN_PORT:-$COLLECTOR_INTROSPECT_PORT}
http_server_ip=$(get_introspect_listen_ip_for_node ANALYTICS)
syslog_port=${COLLECTOR_SYSLOG_LISTEN_PORT:-$COLLECTOR_SYSLOG_PORT}
sflow_port=${COLLECTOR_SFLOW_LISTEN_PORT:-$COLLECTOR_SFLOW_PORT}
ipfix_port=${COLLECTOR_IPFIX_LISTEN_PORT:-$COLLECTOR_IPFIX_PORT}
# log_category=
log_file=$LOG_FOLDER_ABS_PATH/contrail-collector.log
log_files_count=${COLLECTOR_LOG_FILE_COUNT:-10}
log_file_size=${COLLECTOR_LOG_FILE_SIZE:-1048576}
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
# sandesh_send_rate_limit=
EOM
if is_enabled ${ANALYTICSDB_ENABLE} ; then
cat >> /etc/contrail/contrail-collector.conf << EOM
cassandra_server_list=$ANALYTICSDB_CQL_SERVERS
EOM
fi

cat >> /etc/contrail/contrail-collector.conf << EOM
zookeeper_server_list=$ZOOKEEPER_SERVERS

[CASSANDRA]
cassandra_use_ssl=${CASSANDRA_SSL_ENABLE,,}
cassandra_ca_certs=$CASSANDRA_SSL_CA_CERTFILE

[COLLECTOR]
port=${COLLECTOR_LISTEN_PORT:-$COLLECTOR_PORT}
server=${hostip}
protobuf_port=${COLLECTOR_PROTOBUF_LISTEN_PORT:-$COLLECTOR_PROTOBUF_PORT}

[STRUCTURED_SYSLOG_COLLECTOR]
# TCP & UDP port to listen on for receiving structured syslog messages
port=${COLLECTOR_STRUCTURED_SYSLOG_LISTEN_PORT:-$COLLECTOR_STRUCTURED_SYSLOG_PORT}
# List of external syslog receivers to forward structured syslog messages in ip:port format separated by space
# tcp_forward_destination=10.213.17.53:514
EOM
if is_enabled ${ANALYTICS_ALARM_ENABLE} ; then
cat >> /etc/contrail/contrail-collector.conf << EOM
kafka_broker_list=$KAFKA_SERVERS
kafka_topic=${KAFKA_TOPIC:-structured_syslog_topic}
# number of kafka partitions
kafka_partitions=${KAFKA_PARTITIONS:-30}
EOM
fi

cat >> /etc/contrail/contrail-collector.conf << EOM

[API_SERVER]
# List of api-servers in ip:port format separated by space
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_SSL_ENABLE}

EOM
if is_enabled ${ANALYTICSDB_ENABLE} ; then
cat >> /etc/contrail/contrail-collector.conf << EOM
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
EOM
fi

cat >> /etc/contrail/contrail-collector.conf << EOM

[REDIS]
port=$REDIS_SERVER_PORT
server=127.0.0.1
password=$REDIS_SERVER_PASSWORD
EOM

if is_enabled ${ANALYTICS_ALARM_ENABLE} ; then
cat >> /etc/contrail/contrail-collector.conf << EOM
[KAFKA]
kafka_broker_list=$KAFKA_SERVERS
kafka_ssl_enable=${KAFKA_SSL_ENABLE:-${SSL_ENABLE:-False}}
${kafka_ssl_config}
EOM
fi

cat >> /etc/contrail/contrail-collector.conf << EOM
[CONFIGDB]
config_db_server_list=$configdb_cql_servers
config_db_use_ssl=${CASSANDRA_SSL_ENABLE,,}
config_db_ca_certs=$CASSANDRA_SSL_CA_CERTFILE

rabbitmq_server_list=$rabbitmq_server_list
$rabbitmq_config
$rabbitmq_ssl_config

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env COLLECTOR /etc/contrail/contrail-collector.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
