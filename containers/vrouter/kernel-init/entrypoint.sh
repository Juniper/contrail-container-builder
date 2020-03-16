#!/bin/bash

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

source /common.sh
source /agent-functions.sh

enable_kernel_module () {
  local s_dir="$1"
  local d_dir="$2"
  echo "Load vrouter.ko $s_dir for kernel $d_dir"
  mkdir -p /lib/modules/$d_dir/kernel/net/vrouter
  cp -f /opt/contrail/vrouter-kernel-modules/$s_dir/vrouter.ko /lib/modules/$d_dir/kernel/net/vrouter/
  depmod -a $d_dir
}

copy_agent_tools_to_host

mod_dir=$(find /opt/contrail/. -type f -name "vrouter.ko" | awk  -F "/" '{print($(NF-1))}')
available_modules=$(echo "$mod_dir" | sed 's/\.el/ el/' | sort -V | sed 's/ /./1')
printf 'Available vrouter.ko versions:\n'
printf '%s\n' ${available_modules[@]}
k_dir=$(find /lib/modules/. -type d -name "*.x86_64" | awk -F "/" '{print $NF}')
printf 'Installed kernel versions:\n'
printf '%s\n' $k_dir

for d in $k_dir ; do
  if echo "$available_modules" | grep -q "$d" ; then
    enable_kernel_module "$d" "$d"
    continue
  fi
  s=$(echo -e "${available_modules}\n${d}" | sed 's/\.el/ el/' | sort -V | sed 's/ /./1')
  if ! echo "$s" | grep -A1 "$d" | grep -vq "$d" ; then
    enable_kernel_module "${available_modules##*$'\n'}" "$d"
    continue
  fi
  enable_kernel_module $(echo "$s" | grep -A1 "$d" | grep -v "$d") "$d"
done

exec $@
