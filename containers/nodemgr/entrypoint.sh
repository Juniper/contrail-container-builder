#!/bin/bash

source /common.sh

# Env variables:
# NODE_TYPE = name of the component [vrouter, config, control, analytics, database]

VAR_PREFIX=${NODE_TYPE^^}NODEMGR
# ToDo - decide how to resolve this for non-contrail parts
export NODEMGR_TYPE=contrail-${NODE_TYPE}
NODEMGR_NAME=${NODEMGR_TYPE}-nodemgr

log_local=${VAR_PREFIX}_LOG_LOCAL
log_level=${VAR_PREFIX}_LOG_LEVEL
log_file=${VAR_PREFIX}_LOG_FILE

hostip=$(get_listen_ip_for_node ${NODE_TYPE^^})

cat > /etc/contrail/$NODEMGR_NAME.conf << EOM
[DEFAULTS]
log_local=${!log_local:-$LOG_LOCAL}
log_level=${!log_level:-$LOG_LEVEL}
hostip=${hostip}
#contrail_databases=config analytics
#minimum_diskGB=4
#log_category =
log_file=${!log_file:-"$LOG_DIR/$NODEMGR_NAME.log"}

[COLLECTOR]
server_list=${COLLECTOR_SERVERS}

$sandesh_client_config
EOM

add_ini_params_from_env ${NODE_TYPE^^}_NODEMGR /etc/contrail/$NODEMGR_NAME.conf

set_vnc_api_lib_ini

/provision.sh

exec "$@"

