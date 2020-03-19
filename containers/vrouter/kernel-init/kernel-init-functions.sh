#!/bin/bash

enable_kernel_module () {
  local s_dir="$1"
  local d_dir="$2"
  echo "Load vrouter.ko $s_dir for kernel $d_dir"
  mkdir -p /lib/modules/$d_dir/kernel/net/vrouter
  cp -f /opt/contrail/vrouter-kernel-modules/$s_dir/vrouter.ko /lib/modules/$d_dir/kernel/net/vrouter/
  depmod -a $d_dir
}

get_vrouter_dirs () {
  local path=$1
  find "$path" -type f -name "vrouter.ko"
}

get_kernel_dirs () {
  local path=$1
  find "$path" -type d -name "*.x86_64"
}

get_lists_modules_versions () {
  local list_dirs=$1
  echo "$list_dirs" | awk -F "/" '{print($(NF-1))}' | sed 's/\.el/ el/' | sort -V | sed 's/ /./1'
}

get_lists_kernels_versions () {
  local list_dirs=$1
  echo "$list_dirs_kernels" | awk -F "/" '{print $NF}'
}

install_kernel_modules () {
  local modules=$1
  local kernels=$2
  local sorted_list
  local d
  for d in $kernels ; do
    # Enable module if we have equal version
    if echo "$modules" | grep -q "$d" ; then
      enable_kernel_module "$d" "$d"
      continue
    fi
    # Add OS kernel version to list of available and sort them
    sorted_list=$(echo -e "${modules}\n${d}" | sed 's/\.el/ el/' | sort -V | sed 's/ /./1')
    if ! echo "$sorted_list" | grep -B1 "$d" | grep -vq "$d" ; then
      # Enable first installed module if current kernel is upper all modules that we have
      enable_kernel_module $(echo "$modules" | head -1) "$d"
    else
      # Enable upper version kernel module
      enable_kernel_module $(echo "$sorted_list" | grep -B1 "$d" | grep -v "$d") "$d"
    fi
  done
}
