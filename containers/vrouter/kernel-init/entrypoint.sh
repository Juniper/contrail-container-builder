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

# Collect kernel module versions from package
mod_dir=$(find /opt/contrail/. -type f -name "vrouter.ko" | awk  -F "/" '{print($(NF-1))}')
available_modules=$(echo "$mod_dir" | sed 's/\.el/ el/' | sort -V | sed 's/ /./1')
echo "Available vrouter.ko versions:"
echo "$available_modules"
# Collect installed kernels from system
installed_kernels=$(find /lib/modules/. -type d -name "*.x86_64" | awk -F "/" '{print $NF}')
echo "Installed kernel versions:"
echo "$installed_kernels"

for d in $installed_kernels ; do
  # Enable module if we have equal version
  if echo "$available_modules" | grep -q "$d" ; then
    enable_kernel_module "$d" "$d"
    continue
  fi
  # Add OS kernel version to list of available and sort them
  sorted_list=$(echo -e "${available_modules}\n${d}" | sed 's/\.el/ el/' | sort -V | sed 's/ /./1')
  if ! echo "$sorted_list" | grep -B1 "$d" | grep -vq "$d" ; then
    # Enable first installed module if current kernel is upper all modules that we have
    enable_kernel_module $(echo "$available_modules" | head -1) "$d"
  else
    # Enable upper version kernel module
    enable_kernel_module $(echo "$sorted_list" | grep -B1 "$d" | grep -v "$d") "$d"
  fi
done

exec $@
