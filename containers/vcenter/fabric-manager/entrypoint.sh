#!/bin/bash

source /common.sh

cat > /etc/contrail/contrail-vcenter-fabric-manager/config.yaml << EOM
vcenter:
  host: $VCENTER_SERVER
  port: ${VCENTER_PORT:-443}
  username: $VCENTER_USERNAME
  password: $VCENTER_PASSWORD
  preferred_api_versions:
    - ${VCENTER_API_VERSION:-vim.version.version10}
  datacenter: $VCENTER_DATACENTER

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
  introspect_port: 9099
  logging_level: $LOG_LEVEL
  log_file: $LOG_DIR/contrail-vcenter-fabric-manager.log
  http_server_ip: $(get_introspect_listen_ip_for_node VCENTER_FABRIC_MANAGER)

EOM

exec "$@"
