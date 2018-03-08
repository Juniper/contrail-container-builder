#!/bin/bash

source /common.sh

cat > /etc/contrail/ironic-notification-manager.conf << EOM
[DEFAULTS]
log_file = ${IRONIC_NOTIFICATION_MANAGER_LOG_FILE:-"$LOG_DIR/ironic-notification-manager.log"}
log_level = ${IRONIC_NOTIFICATION_MANAGER_LOG_LEVEL:-$LOG_LEVEL}
log_local = 1

rabbit_server = $RABBITMQ_SERVERS
rabbit_port = $RABBITMQ_NODE_PORT
$rabbitmq_auth_config

notification_level = $IRONIC_NOTIFICATION_LEVEL
collectors = $COLLECTOR_SERVERS
introspect_port = ${IRONIC_NOTIFICATION_MANAGER_INTROSPECT_PORT:-8110}
EOM

add_ini_params_from_env IRONIC_NOTIFICATION_MANAGER /etc/contrail/ironic-notification-manager.conf

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
