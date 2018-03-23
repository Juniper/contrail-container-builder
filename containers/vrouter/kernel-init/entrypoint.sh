#!/bin/bash

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

source /common.sh
source /agent-functions.sh

copy_agent_tools_to_host

# Load kernel module
if lsmod | grep -q vrouter; then
  echo "INFO: vrouter.ko already loaded in the system"
  # TODO: handle upgrade
else
  kver=`uname -r | awk -F "-" '{print $1}'`
  echo "INFO: Load kernel module for kver=${kver}"
  modfile=`ls -1rt /opt/contrail/vrouter-kernel-modules/${kver}-*/vrouter.ko | tail -1`
  for k_dir in `ls -d /lib/modules/*` ; do
    mkdir -p ${k_dir}/kernel/net/vrouter
    cp -f ${modfile} ${k_dir}/kernel/net/vrouter
  done
  depmod -a
  free -h && sync && echo 2 >/proc/sys/vm/drop_caches && free -h
  load_kernel_module vrouter
fi

exec $@
