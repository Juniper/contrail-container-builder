#!/bin/bash

# these next folders must be mounted to compile vrouter.ko in ubuntu: /usr/src /lib/modules

source /common.sh
source /agent-functions.sh
source /kernel-init-functions.sh

copy_agent_tools_to_host

get_dirs_lists
get_lists_versions
install_kernel_modules

exec $@
