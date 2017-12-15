#!/bin/bash

source /common.sh

host_ip=$(get_listen_ip_for_node ANALYTICS)

cat > /etc/contrail/contrail-analytics-api.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
http_server_port=${ANALYTICS_API_INTROSPECT_LISTEN_PORT:-$ANALYTICS_API_INTROSPECT_PORT}
rest_api_port=${ANALYTICS_API_LISTEN_PORT:-$ANALYTICS_API_PORT}
rest_api_ip=${ANALYTICS_API_LISTEN_IP:-0.0.0.0}
partitions=${ANALYTICS_UVE_PARTITIONS:-30}
aaa_mode=$AAA_MODE
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
zk_list=$ZOOKEEPER_ANALYTICS_SERVERS_SPACE_DELIM

[REDIS]
redis_query_port=$REDIS_SERVER_PORT
redis_uve_list=$REDIS_SERVERS

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

provision_node provision_analytics_node.py $host_ip $DEFAULT_HOSTNAME

exec "$@"
