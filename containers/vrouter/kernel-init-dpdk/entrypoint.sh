#!/bin/bash

source /common.sh
source /agent-functions.sh

copy_agent_tools_to_host

exec $@
