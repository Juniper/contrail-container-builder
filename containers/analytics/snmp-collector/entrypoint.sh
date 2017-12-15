#!/bin/bash

source /common.sh

rabbitmq_server_list=$(echo $RABBITMQ_SERVERS | sed 's/,/ /g')
config_db_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-snmp-collector.conf << EOM
[DEFAULTS]
scan_frequency=${SNMPCOLLECTOR_SCAN_FREQUENCY:-600}
fast_scan_frequency=${SNMPCOLLECTOR_FAST_SCAN_FREQUENCY:-60}
http_server_port=${SNMPCOLLECTOR_INTROSPECT_LISTEN_PORT:-$SNMPCOLLECTOR_INTROSPECT_PORT}
log_local=${SNMPCOLLECTOR_LOG_LOCAL:-$LOG_LOCAL}
log_level=${SNMPCOLLECTOR_LOG_LEVEL:-$LOG_LEVEL}
log_file=${SNMPCOLLECTOR_LOG_FILE:-"$LOG_DIR/contrail-snmp-collector.log"}
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
