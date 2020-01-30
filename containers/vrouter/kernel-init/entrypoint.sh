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
available_modules=( $( echo "$mod_dir" | sed 's/\.el/ el/' | sort -V | sed 's/ /./1') )
printf 'Available vrouter.ko versions:\n'
printf '%s\n' ${available_modules[@]}
k_dir=$(find /lib/modules/. -type d -name "*.x86_64" | awk -F "/" '{print $NF}')
kernels_list=( $( printf  '%s\n' $k_dir ${available_modules[@]} | sed 's/\.el/ el/' | sort -V | sed 's/ /./1' | uniq ) )
printf 'Installed kernel versions:\n'
printf '%s\n' $k_dir

i=$((${#available_modules[@]}-1))
for r in $(printf  '%s\n' ${kernels_list[@]} | tac) ; do
  [[ "$r" == "${available_modules[$i]}" ]] && ((i--))
done
((i++))

offset=0
for l in ${kernels_list[@]} ; do
  [[ "$l" == "${available_modules[$i]}" ]] && [[ "$i" != "$((${#available_modules[@]}-1))" ]] && ((i++)) && offset=0
  [[ "$l" == "${kernels_list[0]}" && "$l" == ${available_modules[$(($i-1))]} ]] &&  offset=-1
  [[ -d "/lib/modules/${l}" ]] && enable_kernel_module "${available_modules[$(($i+$offset))]}" "$l"
done

exec $@
