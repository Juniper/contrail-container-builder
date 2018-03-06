#!/bin/bash

source /common.sh

hostip=$(get_listen_ip_for_node ANALYTICS)

cat > /etc/contrail/contrail-query-engine.conf << EOM
[DEFAULT]
analytics_data_ttl=${ANALYTICS_DATA_TTL:-48}
hostip=${hostip}
hostname=${DEFAULT_HOSTNAME}
http_server_port=${QUERYENGINE_INTROSPECT_LISTEN_PORT:-$QUERYENGINE_INTROSPECT_PORT}
log_local=${QUERYENGINE_LOG_LOCAL:-$LOG_LOCAL}
log_level=${QUERYENGINE_LOG_LEVEL:-$LOG_LEVEL}
log_file=${QUERYENGINE_LOG_FILE:-"$LOG_DIR/contrail-query-engine.log"}
max_slice=${QUERYENGINE_MAX_SLICE:-100}
max_tasks=${QUERYENGINE_MAX_TASKS:-16}
start_time=${QUERYENGINE_START_TIME:-0}
# Sandesh send rate limit can be used to throttle system logs transmitted per
# second. System logs are dropped if the sending rate is exceeded
# sandesh_send_rate_limit=
cassandra_server_list=$ANALYTICSDB_CQL_SERVERS
collectors=$COLLECTOR_SERVERS

[REDIS]
port=$REDIS_SERVER_PORT
server=$REDIS_SERVER_IP

$sandesh_client_config
EOM

add_ini_params_from_env QUERY_ENGINE /etc/contrail/contrail-query-engine.conf

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
