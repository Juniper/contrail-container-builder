#!/bin/bash

source /common.sh
source /agent-functions.sh

copy_agent_tools_to_host
# the following func requires mount /etc/contrail from host to /host/etc/contrail in container
prepare_vif_config $AGENT_MODE /host

exec $@
