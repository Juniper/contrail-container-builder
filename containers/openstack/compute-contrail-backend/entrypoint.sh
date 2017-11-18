#!/bin/bash

set -ex
mkdir -p /opt/plugin/bin
cp /usr/bin/vrouter-port-control /opt/plugin/bin/

cp /nova-compute.sh /opt/plugin/nova-compute.sh
