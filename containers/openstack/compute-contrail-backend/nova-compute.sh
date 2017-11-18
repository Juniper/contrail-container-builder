#!/bin/bash

set -ex

export PATH=$PATH:/opt/plugin/bin

console_kind="{{- .Values.console.console_kind -}}"
if [ "${console_kind}" == "novnc" ] ; then
exec nova-compute \
      --config-file /etc/nova/nova.conf \
      --config-file /tmp/pod-shared/nova-vnc.ini
else
exec nova-compute \
      --config-file /etc/nova/nova.conf
fi
