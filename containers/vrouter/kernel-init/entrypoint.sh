#!/bin/bash

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

source /common.sh
source /agent-functions.sh

enable_kernel_module () {
  mkdir -p /lib/modules/$1/kernel/net/vrouter
  cp -f /opt/contrail/$1/vrouter.ko /lib/modules/$1/kernel/net/vrouter
  depmod -a $1
}

copy_agent_tools_to_host

# get versions vrouter.ko
mod_dir=$(find /opt/contrail/. -type f -name "vrouter.ko" | awk  -F "/" '{print($(NF-1))}')
# get installed kernels
k_dir=$(ls /lib/modules)
# get os & architecture
os_arch=$(echo "$mod_dir" | tail -1 | awk -F '.' -v OFS='.' '{print ($(NF-1),($NF))}')
# get latest version vrouter.ko
latest_k_mod=$( echo "$mod_dir" | sed "s/\.$os_arch//" | sort -V | tail -n1 )
# get kernels with versions higher than the latest vrouter.ko version
# names truncation for correct "sort -V" execution
high_k_vers=$( printf '%s\n' $k_dir $latest_k_mod | sed "s/\.$os_arch//" | sort -V | uniq | awk "/$latest_k_mod/ ? c++ : c" )

# install vrouter.ko according to a specific kernel version
for v in $mod_dir; do
  short_v=$( echo $v | cut -d "." -f1,2,3 )
  # Install completely identical kernel versions
  if [[ "$k_dir" =~ "$v" ]]; then
    enable_kernel_module "$v"
  else
    # Install vrouter.ko ignoring kernel fixes
    if [[ "$k_dir" =~ "$short_v" ]]; then
      enable_kernel_module "$v"
    fi
  fi
done

# installation of kernel modules for undefined previous kernel versions is skipped due to possible collisions

# install the latest vrouter.ko to all higher kernel version
if [[ -n "$high_k_vers" ]]; then
  for k in $high_k_vers ; do
    enable_kernel_module "${k}.${os_arch}"
  done
fi

exec $@
