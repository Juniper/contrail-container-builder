#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-topology.conf << EOM
[DEFAULTS]
scan_frequency=${TOPOLOGY_SCAN_FREQUENCY:-600}
http_server_port=${TOPOLOGY_INTROSPECT_LISTEN_PORT:-$TOPOLOGY_INTROSPECT_PORT}
log_local=${TOPOLOGY_LOG_LOCAL:-$LOG_LOCAL}
log_level=${TOPOLOGY_LOG_LEVEL:-$LOG_LEVEL}
log_file=${TOPOLOGY_LOG_FILE:-"$LOG_DIR/contrail-topology.log"}
analytics_api=${TOPOLOGY_ANALYTICS_API_SERVERS:-127.0.0.1:$ANALYTICS_API_PORT}
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
