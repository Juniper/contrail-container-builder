#!/bin/bash

set -ex
COMMAND="${@:-start}"

export PYTHONPATH=/opt/plugin/site-packages

function start () {
  exec neutron-server \
        --config-file /etc/neutron/neutron.conf \
        --config-file /etc/neutron/plugins/opencontrail/ContrailPlugin.ini
}

function stop () {
  kill -TERM 1
}

$COMMAND
