#!/bin/bash

source /common.sh
source /agent-functions.sh

if [[ ${CLOUD_ORCHESTRATOR} == "kubernetes" ]]; then
    cleanup_contrail_cni_config
fi

if [[ ${CLOUD_ORCHESTRATOR} == "mesos" ]]; then
    cleanup_mesos_cni_config
fi

echo "INFO: Going to remove vhost0 interface"

remove_vhost0

cleanup_vrouter_agent_files

echo "INFO: starting to uninstall kernel module"
unload_kernel_module vrouter
