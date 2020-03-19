#!/bin/bash

enable_kernel_module () {
  local s_dir="$1"
  local d_dir="$2"
  echo "Load vrouter.ko $s_dir for kernel $d_dir"
  mkdir -p /lib/modules/$d_dir/kernel/net/vrouter
  cp -f /opt/contrail/vrouter-kernel-modules/$s_dir/vrouter.ko /lib/modules/$d_dir/kernel/net/vrouter/
  depmod -a $d_dir
}

get_dirs_lists () {
list_dirs_modules=$( find /opt/contrail/. -type f -name "vrouter.ko" )
list_dirs_kernels=$( find /lib/modules/. -type d -name "*.x86_64" )
}

get_lists_versions () {
  available_modules=$( echo "$list_dirs_modules" | awk -F "/" '{print($(NF-1))}' | sed 's/\.el/ el/' | sort -V | sed 's/ /./1' )
  installed_kernels=$( echo "$list_dirs_kernels" | awk -F "/" '{print $NF}' )
  echo "Available vrouter.ko versions:"
  echo "$available_modules"
  echo "Installed kernel versions:"
  echo "$installed_kernels"
}

install_kernel_modules () {
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
}
