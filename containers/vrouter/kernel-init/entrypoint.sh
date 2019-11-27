#!/bin/bash

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

source /common.sh
source /agent-functions.sh

copy_agent_tools_to_host

modfile="/opt/contrail/vrouter-kernel-modules/vrouter.ko"
for k_dir in `ls -d /lib/modules/*` ; do
  mkdir -p ${k_dir}/kernel/net/vrouter
  cp -f ${modfile} ${k_dir}/kernel/net/vrouter
  depmod -a $(echo $k_dir | awk -F '/' '{print $NF}')
done

exec $@
