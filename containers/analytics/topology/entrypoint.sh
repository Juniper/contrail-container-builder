#!/bin/bash

source /common.sh

pre_start_init

rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
config_db_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')
if [[ "$SECURE_INTROSPECT" == True ]]; then
  ANALYTICS_INTROSPECT_IP=$(get_listen_ip_for_node ANALYTICS_INTROSPECT)
fi

cat > /etc/contrail/contrail-topology.conf << EOM
[DEFAULTS]
scan_frequency=${TOPOLOGY_SCAN_FREQUENCY:-600}
http_server_port=${TOPOLOGY_INTROSPECT_LISTEN_PORT:-$TOPOLOGY_INTROSPECT_PORT}
http_server_ip=${ANALYTICS_INTROSPECT_IP:-0.0.0.0}
log_file=$LOG_DIR/contrail-topology.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
analytics_api=${TOPOLOGY_ANALYTICS_API_SERVERS:-127.0.0.1:$ANALYTICS_API_PORT}
collectors=$COLLECTOR_SERVERS
zookeeper=$ZOOKEEPER_ANALYTICS_SERVERS

[API_SERVER]
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_USE_SSL:-False}

[CONFIGDB]
config_db_server_list=$config_db_server_list

rabbitmq_server_list=$rabbitmq_server_list
$rabbitmq_config
$rabbitmq_ssl_config

$sandesh_client_config
EOM

add_ini_params_from_env TOPOLOGY /etc/contrail/contrail-topology.conf

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
