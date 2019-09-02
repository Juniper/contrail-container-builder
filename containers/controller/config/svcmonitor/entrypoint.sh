#!/bin/bash

source /common.sh

pre_start_init

host_ip=$(get_listen_ip_for_node CONFIG)
cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-svc-monitor.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
http_server_ip=$(get_introspect_listen_ip_for_node CONFIG)
api_server_ip=$CONFIG_NODES
api_server_port=$CONFIG_API_PORT
api_server_use_ssl=${CONFIG_API_SSL_ENABLE}
log_file=$LOG_DIR/contrail-svc-monitor.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
cassandra_server_list=$cassandra_server_list
cassandra_use_ssl=${CASSANDRA_SSL_ENABLE,,}
cassandra_ca_certs=$CASSANDRA_SSL_CA_CERTFILE
zk_server_ip=$ZOOKEEPER_SERVERS

rabbit_server=$RABBITMQ_SERVERS
$rabbit_config
$kombu_ssl_config

collectors=$COLLECTOR_SERVERS

[SECURITY]
use_certs=${SSL_ENABLE}
keyfile=${SERVER_KEYFILE}
certfile=${SERVER_CERTFILE}
ca_certs=${SERVER_CA_CERTFILE}

[SCHEDULER]
# Analytics server list used to get vrouter status and schedule service instance
analytics_server_list=$ANALYTICS_SERVERS
aaa_mode = $AAA_MODE
analytics_api_ssl_enable = ${ANALYTICS_API_SSL_ENABLE}
analytics_api_insecure_enable = ${SSL_INSECURE}
analytics_api_ssl_certfile = ${ANALYTICS_API_SERVER_CERTFILE}
analytics_api_ssl_keyfile = ${ANALYTICS_API_SERVER_KEYFILE}
analytics_api_ssl_ca_cert = ${ANALYTICS_API_SERVER_CA_CERTFILE}

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env SVC_MONITOR /etc/contrail/contrail-svc-monitor.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
