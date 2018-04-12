#!/bin/bash

source /common.sh
source /agent-functions.sh

if [[ ${CLOUD_ORCHESTRATOR} == "kubernetes" ]]; then
    cleanup_contrail_cni_config
fi

quit_root_process
