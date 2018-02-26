#!/bin/bash

source /common.sh

cat > /etc/contrail/ironic-notification-manager.conf << EOM
[DEFAULTS]
log_file = ${IRONIC_NOTIFICATION_MANAGER_LOG_FILE:-"$LOG_DIR/ironic-notification-manager.log"}
log_level = ${IRONIC_NOTIFICATION_MANAGER_LOG_LEVEL:-$LOG_LEVEL}
log_local = 1
rabbit_server = $RABBITMQ_SERVERS
rabbit_port = $RABBITMQ_NODE_PORT
rabbit_user = $RABBITMQ_USER
rabbit_password = $RABBITMQ_PASSWORD
notification_level = $IRONIC_NOTIFICATION_LEVEL
collectors = $COLLECTOR_SERVERS
introspect_port = ${IRONIC_NOTIFICATION_MANAGER_INTROSPECT_PORT:-8110}

EOM

set_third_party_auth_config
set_vnc_api_lib_ini
ensure_log_dir /var/log/contrail

exec "$@"
