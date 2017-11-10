#!/bin/bash

source /common.sh

log_local=${VAR_PREFIX}_LOG_LOCAL
log_level=${VAR_PREFIX}_LOG_LEVEL
log_file=${VAR_PREFIX}_LOG_FILE

cat > /etc/contrail/$NODEMGR_NAME.conf << EOM
[DEFAULTS]
log_local=${!log_local:-$LOG_LOCAL}
log_level=${!log_level:-$LOG_LEVEL}
hostip=$DEFAULT_LOCAL_IP
#contrail_databases=config analytics
#minimum_diskGB=4
#log_category =
log_file=${!log_file:-"$LOG_DIR/$NODEMGR_NAME.log"}

[COLLECTOR]
server_list=${COLLECTOR_SERVERS}

$sandesh_client_config
EOM

set_vnc_api_lib_ini

exec "$@"
