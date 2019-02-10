#!/bin/bash

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

source /common.sh
source /agent-functions.sh

copy_agent_tools_to_host

kver=`uname -r | awk -F "-" '{print $1}'`
echo "INFO: copy kernel module for kver=${kver} to host"
modfile=`ls -1rt /opt/contrail/vrouter-kernel-modules/${kver}-*/vrouter.ko | tail -1`
for k_dir in `ls -d /lib/modules/*` ; do
  mkdir -p ${k_dir}/kernel/net/vrouter
  cp -f ${modfile} ${k_dir}/kernel/net/vrouter
done
depmod -a

# OPTIONAL vrouter limit parameter
vrouter_params="options vrouter"
mpls_labels="vr_mpls_labels=$VR_MPLS_LABELS"
nexthops="vr_nexthops=$VR_NEXTHOPS"
vrfs="vr_vrfs=$VR_VRFS"
macs="vr_bridge_entries=$VR_BRIDGE_ENTRIES"
flow_entries="vr_flow_entries=$VR_FLOW_ENTRIES"
vrouter_params="$vrouter_params $mpls_labels $nexthops $vrfs $macs $flow_entries"
echo ${vrouter_params} > /etc/modprobe.d/vrouter.conf

exec $@
