#!/bin/bash

source /common.sh

pre_start_init

hostip=$(get_listen_ip_for_node ANALYTICSDB)
hostname=$(resolve_hostname_by_ip $hostip)

cat > /etc/contrail/contrail-query-engine.conf << EOM
[DEFAULT]
analytics_data_ttl=${ANALYTICS_DATA_TTL:-48}
hostip=${hostip}
hostname=${hostname:-$(get_default_hostname)}
http_server_ip=$(get_introspect_listen_ip_for_node ANALYTICSDB)
http_server_port=${QUERYENGINE_INTROSPECT_LISTEN_PORT:-$QUERYENGINE_INTROSPECT_PORT}
log_file=$LOG_DIR/contrail-query-engine.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
max_slice=${QUERYENGINE_MAX_SLICE:-100}
max_tasks=${QUERYENGINE_MAX_TASKS:-16}
start_time=${QUERYENGINE_START_TIME:-0}
# Sandesh send rate limit can be used to throttle system logs transmitted per
# second. System logs are dropped if the sending rate is exceeded
# sandesh_send_rate_limit=
cassandra_server_list=$ANALYTICSDB_CQL_SERVERS
collectors=$COLLECTOR_SERVERS

[CASSANDRA]
cassandra_use_ssl=${CASSANDRA_SSL_ENABLE,,}
cassandra_ca_certs=$CASSANDRA_SSL_CA_CERTFILE

[REDIS]
server_list=$REDIS_SERVERS
password=$REDIS_SERVER_PASSWORD
redis_ssl_enable=$REDIS_SSL_ENABLE
${redis_ssl_config}

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env QUERY_ENGINE /etc/contrail/contrail-query-engine.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
