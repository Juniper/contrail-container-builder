#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-snmp-collector.conf << EOM
[DEFAULTS]
scan_frequency=${SNMPCOLLECTOR_SCAN_FREQUENCY:-600}
fast_scan_frequency=${SNMPCOLLECTOR_FAST_SCAN_FREQUENCY:-60}
http_server_port=${SNMPCOLLECTOR_INTROSPECT_LISTEN_PORT:-$SNMPCOLLECTOR_INTROSPECT_PORT}
log_local=${SNMPCOLLECTOR_LOG_LOCAL:-$LOG_LOCAL}
log_level=${SNMPCOLLECTOR_LOG_LEVEL:-$LOG_LEVEL}
log_file=${SNMPCOLLECTOR_LOG_FILE:-"$LOG_DIR/contrail-snmp-collector.log"}
collectors=$COLLECTOR_SERVERS
zookeeper=$ZOOKEEPER_SERVERS

[API_SERVER]
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_USE_SSL:-False}

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
