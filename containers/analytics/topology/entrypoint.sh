#!/bin/bash

source /common.sh

rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
config_db_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-topology.conf << EOM
[DEFAULTS]
scan_frequency=${TOPOLOGY_SCAN_FREQUENCY:-600}
http_server_port=${TOPOLOGY_INTROSPECT_LISTEN_PORT:-$TOPOLOGY_INTROSPECT_PORT}
log_local=${TOPOLOGY_LOG_LOCAL:-$LOG_LOCAL}
log_level=${TOPOLOGY_LOG_LEVEL:-$LOG_LEVEL}
log_file=${TOPOLOGY_LOG_FILE:-"$LOG_DIR/contrail-topology.log"}
analytics_api=${TOPOLOGY_ANALYTICS_API_SERVERS:-127.0.0.1:$ANALYTICS_API_PORT}
collectors=$COLLECTOR_SERVERS
zookeeper=$ZOOKEEPER_ANALYTICS_SERVERS

[API_SERVER]
api_server_list=$CONFIG_SERVERS
api_server_use_ssl=${CONFIG_API_USE_SSL:-False}

[CONFIGDB]
rabbitmq_server_list=$rabbitmq_server_list
rabbitmq_vhost=$RABBITMQ_VHOST
rabbitmq_user=$RABBITMQ_USER
rabbitmq_password=$RABBITMQ_PASSWORD
rabbitmq_use_ssl=$RABBITMQ_USE_SSL
config_db_server_list=$config_db_server_list

$sandesh_client_config
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
