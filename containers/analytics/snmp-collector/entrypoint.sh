#!/bin/bash

source /common.sh
export SNMPCONFPATH=${SNMPCONFPATH:-/etc/contrail}

pre_start_init

host_ip=$(get_listen_ip_for_node ANALYTICS)
rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
config_db_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-snmp-collector.conf << EOM
[DEFAULTS]
host_ip=${host_ip}
scan_frequency=${SNMPCOLLECTOR_SCAN_FREQUENCY:-600}
fast_scan_frequency=${SNMPCOLLECTOR_FAST_SCAN_FREQUENCY:-60}
http_server_ip=$(get_introspect_listen_ip_for_node ANALYTICS)
http_server_port=${SNMPCOLLECTOR_INTROSPECT_LISTEN_PORT:-$SNMPCOLLECTOR_INTROSPECT_PORT}
log_file=$LOG_DIR/contrail-snmp-collector.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
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

add_ini_params_from_env SNMP_COLLECTOR /etc/contrail/contrail-snmp-collector.conf

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
