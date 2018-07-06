#!/bin/bash

source /common.sh

api_hostname=${CONFIG_API_VIP:-$(get_vip_for_node CONFIG)}

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
  api_server_host: $api_hostname
  api_server_port: $CONFIG_API_PORT
  auth_host: $KEYSTONE_AUTH_HOST
  auth_port: $KEYSTONE_AUTH_PUBLIC_PORT
  username:  $KEYSTONE_AUTH_ADMIN_USERNAME
  password:  $KEYSTONE_AUTH_ADMIN_PASSWORD
  tenant_name: $KEYSTONE_AUTH_ADMIN_TENANT

sandesh:
  collectors: $COLLECTOR_SERVERS
  introspect_port: 9090
  logging_level: SYS_INFO
  log_file: /var/log/contrail/contrail-vcenter-manager.log


EOM

exec "$@"
