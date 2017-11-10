#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-analytics-api.conf << EOM
[DEFAULTS]
host_ip=${ANALYTICS_API_LISTEN_IP:-`get_listen_ip`}
http_server_port=${ANALYTICS_API_INTROSPECT_LISTEN_PORT:-$ANALYTICS_API_INTROSPECT_PORT}
rest_api_port=${ANALYTICS_API_LISTEN_PORT:-$ANALYTICS_API_PORT}
rest_api_ip=${ANALYTICS_API_LISTEN_IP:-0.0.0.0}
partitions=${ANALYTICS_UVE_PARTITIONS:-30}
aaa_mode=${ANALYTICS_API_AAA_MODE:-no-auth}
log_file=${ANALYTICS_API_LOG_FILE:-"$LOG_DIR/contrail-analytics-api.log"}
log_level=${ANALYTICS_API_LOG_LEVEL:-$LOG_LEVEL}
#log_category = 
log_local=${ANALYTICS_API_LOG_LOCAL:-$LOG_LOCAL}
# Sandesh send rate limit can be used to throttle system logs transmitted per
# second. System logs are dropped if the sending rate is exceeded
#sandesh_send_rate_limit =
collectors=$COLLECTOR_SERVERS
cassandra_server_list=$ANALYTICSDB_CQL_SERVERS
api_server=$CONFIG_SERVERS
zk_list=${ZOOKEEPER_SERVERS:-`get_server_list ZOOKEEPER ":$ZOOKEEPER_PORT "`}

[REDIS]
#server=${ANALYTICS_redis_server:-127.0.0.1}
#redis_server_port=${ANALYTICS_redis_server_port:-6379}
redis_query_port=$REDIS_SERVER_PORT
#redis_uve_list = 127.0.0.1:6379
redis_uve_list=$REDIS_SERVERS

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
