#!/bin/bash

source /common.sh

cat > /etc/contrail/vcenter-manager.conf << EOM
esxi:
  host:
  port: 443
  username:
  password:
  preferred_api_versions:
    - vim.version.version10
  datacenter:

vcenter:
  host:
  port: 443
  username:
  password:
  preferred_api_versions:
    - vim.version.version10
  datacenter:

vnc:
  api_server_host:
  api_server_port: 8082
  auth_host:
  auth_port: 5000
  username:
  password:
  tenant_name:

EOM

exec "$@"
