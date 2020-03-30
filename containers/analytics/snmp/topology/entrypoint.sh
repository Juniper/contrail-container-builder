#!/bin/bash

source /common.sh

pre_start_init

host_ip=$(get_listen_ip_for_node ANALYTICS_SNMP)
rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
config_db_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-topology.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
scan_frequency=${TOPOLOGY_SCAN_FREQUENCY:-600}
http_server_port=${TOPOLOGY_INTROSPECT_LISTEN_PORT:-$TOPOLOGY_INTROSPECT_PORT}
http_server_ip=$(get_introspect_listen_ip_for_node ANALYTICS_SNMP)
log_file=$LOG_FOLDER_ABS_PATH/contrail-topology.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
analytics_api=$ANALYTICS_SERVERS
collectors=$COLLECTOR_SERVERS
zookeeper=$ZOOKEEPER_SERVERS

[API_SERVER]
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_SSL_ENABLE}

[CONFIGDB]
config_db_server_list=$config_db_server_list
config_db_use_ssl=${CASSANDRA_SSL_ENABLE,,}
config_db_ca_certs=$CASSANDRA_SSL_CA_CERTFILE

rabbitmq_server_list=$rabbitmq_server_list
$rabbitmq_config
$rabbitmq_ssl_config

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env TOPOLOGY /etc/contrail/contrail-topology.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
