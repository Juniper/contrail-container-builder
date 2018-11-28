#!/bin/bash

source /common.sh
source /agent-functions.sh

if [[ ${CLOUD_ORCHESTRATOR} == "kubernetes" ]]; then
    cleanup_contrail_cni_config
fi

if [[ ${CLOUD_ORCHESTRATOR} == "mesos" ]]; then
    cleanup_mesos_cni_config
fi

quit_root_process
