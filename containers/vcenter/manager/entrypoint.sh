#!/bin/bash

source /common.sh

introspect_ip='0.0.0.0'
if ! is_enabled ${INTROSPECT_LISTEN_ALL} ; then
  introspect_ip=$(get_ip_for_vrouter_from_control)
fi

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-vcenter-manager/config.yaml << EOM
esxi:
  host: $ESXI_HOST
  port: ${ESXI_PORT:-443}
  username: $ESXI_USERNAME
  password: $ESXI_PASSWORD
  preferred_api_versions:
    - ${VCENTER_API_VERSION:-vim.version.version10}

vcenter:
  host: $VCENTER_SERVER
  port: ${VCENTER_PORT:-443}
  username: $VCENTER_USERNAME
  password: $VCENTER_PASSWORD
  preferred_api_versions:
    - ${VCENTER_API_VERSION:-vim.version.version10}
  datacenter: $VCENTER_DATACENTER
  dvswitch: $VCENTER_DVSWITCH

vnc:
  api_server_host: $CONFIG_NODES
  api_server_port: $CONFIG_API_PORT
  auth_host: $KEYSTONE_AUTH_HOST
  auth_port: $KEYSTONE_AUTH_PUBLIC_PORT
  username:  $KEYSTONE_AUTH_ADMIN_USERNAME
  password:  $KEYSTONE_AUTH_ADMIN_PASSWORD
  tenant_name: $KEYSTONE_AUTH_ADMIN_TENANT

sandesh:
  collectors: $COLLECTOR_SERVERS
  introspect_port: 9090
  logging_level: $LOG_LEVEL
  log_file: $CONTAINER_LOG_DIR/contrail-vcenter-manager.log
  http_server_ip: $introspect_ip

EOM

exec "$@"

