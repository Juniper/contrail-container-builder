#!/bin/bash

source /common.sh

cat > /etc/contrail/ironic-notification-manager.conf << EOM
[DEFAULTS]
log_file = ${INMGR_LOG_FILE:-"$LOG_DIR/ironic-notification-manager.log"}
log_level = ${INMGR_LOG_LEVEL:-$LOG_LEVEL}
log_local = 1
rabbit_server = $RABBITMQ_SERVERS
rabbit_port = $RABBITMQ_NODE_PORT
rabbit_user = $RABBITMQ_USER
rabbit_password = $RABBITMQ_PASSWORD
rabbit_ha_mode = $RABBITMQ_HA_MODE
ironic_server_ip = $OPENSTACK_VIP
ironic_server_port = $IRONIC_SERVER_PORT
collectors = $COLLECTOR_SERVERS
introspect_port = $INMGR_INTROSPECT_PORT
auth_server = $KEYSTONE_AUTH_HOST
auth_port = $KEYSTONE_AUTH_ADMIN_PORT

[KEYSTONE]
admin_user = $KEYSTONE_AUTH_ADMIN_USER
admin_password = $KEYSTONE_AUTH_ADMIN_PASSWORD
admin_tenant_name = $KEYSTONE_AUTH_ADMIN_TENANT
auth_protocol = $KEYSTONE_AUTH_PROTO

EOM

set_third_party_auth_config

exec "$@"
