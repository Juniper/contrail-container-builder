#!/bin/bash

source /common.sh

pre_start_init

cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')
host_ip=$(get_listen_ip_for_node CONFIG)
if [[ "$SECURE_INTROSPECT" == True ]]; then
  CONFIG_INTROSPECT_IP=${host_ip}
fi

cat > /etc/contrail/contrail-svc-monitor.conf << EOM
[DEFAULTS]
http_server_ip=${CONFIG_INTROSPECT_IP:-0.0.0.0}
api_server_ip=$CONFIG_NODES
api_server_port=$CONFIG_API_PORT
log_file=$LOG_DIR/contrail-svc-monitor.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
cassandra_server_list=$cassandra_server_list
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

$sandesh_client_config
EOM

add_ini_params_from_env SVC_MONITOR /etc/contrail/contrail-svc-monitor.conf

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
