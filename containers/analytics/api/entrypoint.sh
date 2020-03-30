#!/bin/bash

source /common.sh

pre_start_init
wait_redis_certs_if_ssl_enabled
wait_analytics_api_certs_if_ssl_enabled

host_ip=$(get_listen_ip_for_node ANALYTICS)

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-analytics-api.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
http_server_port=${ANALYTICS_API_INTROSPECT_LISTEN_PORT:-$ANALYTICS_API_INTROSPECT_PORT}
http_server_ip=$(get_introspect_listen_ip_for_node ANALYTICS)
rest_api_port=${ANALYTICS_API_LISTEN_PORT:-$ANALYTICS_API_PORT}
rest_api_ip=${ANALYTICS_API_LISTEN_IP:-$host_ip}
EOM
if is_enabled ${ANALYTICSDB_ENABLE} ; then
cat >> /etc/contrail/contrail-analytics-api.conf << EOM
partitions=${ANALYTICS_UVE_PARTITIONS:-30}
EOM
fi

cat >> /etc/contrail/contrail-analytics-api.conf << EOM
aaa_mode=$AAA_MODE
log_file=$CONTAINER_LOG_DIR/contrail-analytics-api.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
# Sandesh send rate limit can be used to throttle system logs transmitted per
# second. System logs are dropped if the sending rate is exceeded
#sandesh_send_rate_limit =
collectors=$COLLECTOR_SERVERS
api_server=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_SSL_ENABLE}
zk_list=$ZOOKEEPER_SERVERS_SPACE_DELIM
${analytics_api_ssl_opts}

[REDIS]
EOM

if is_enabled ${ANALYTICSDB_ENABLE} ; then
cat >> /etc/contrail/contrail-analytics-api.conf << EOM
redis_query_port=$REDIS_SERVER_PORT
EOM
fi
cat >> /etc/contrail/contrail-analytics-api.conf << EOM
redis_uve_list=$REDIS_SERVERS
redis_password=$REDIS_SERVER_PASSWORD
redis_use_ssl=$REDIS_SSL_ENABLE
${redis_ssl_config}

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env ANALYTICS_API /etc/contrail/contrail-analytics-api.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
