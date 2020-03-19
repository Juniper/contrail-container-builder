#!/bin/bash

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

source /common.sh
source /agent-functions.sh
source /kernel-init-functions.sh

copy_agent_tools_to_host

list_dirs_modules=$( get_vrouter_dirs "/opt/contrail/." )
list_dirs_kernels=$( get_kernel_dirs "/lib/modules/." )
available_modules=$( get_lists_modules_versions "$list_dirs_modules" )
installed_kernels=$( get_lists_kernels_versions "$list_dirs_kernels" )
echo "Available vrouter.ko versions:"
echo "$available_modules"
echo "Installed kernel versions:"
echo "$installed_kernels"

install_kernel_modules "$available_modules" "$installed_kernels"

exec $@
