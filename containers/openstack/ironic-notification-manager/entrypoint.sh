#!/bin/bash

source /common.sh

mkdir -p /etc/contrail
cat > /etc/contrail/ironic-notification-manager.conf << EOM
[DEFAULTS]
log_file = $CONTAINER_LOG_DIR/ironic-notification-manager.log
log_level = $LOG_LEVEL
log_local = $LOG_LOCAL

rabbit_server = $RABBITMQ_SERVERS
rabbit_port = $RABBITMQ_NODE_PORT
$rabbit_config
$kombu_ssl_config

notification_level = $IRONIC_NOTIFICATION_LEVEL
collectors = $COLLECTOR_SERVERS
introspect_port = ${IRONIC_NOTIFICATION_MANAGER_INTROSPECT_PORT:-8110}
EOM

add_ini_params_from_env IRONIC_NOTIFICATION_MANAGER /etc/contrail/ironic-notification-manager.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
