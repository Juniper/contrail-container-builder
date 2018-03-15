#!/bin/bash

source /common.sh

# Env variables:
# NODE_TYPE = name of the component [vrouter, config, control, analytics, database]

VAR_PREFIX=${NODE_TYPE^^}NODEMGR
# ToDo - decide how to resolve this for non-contrail parts
export NODEMGR_TYPE=contrail-${NODE_TYPE}
NODEMGR_NAME=${NODEMGR_TYPE}-nodemgr

hostip=$(get_listen_ip_for_node ${NODE_TYPE^^})

cat > /etc/contrail/$NODEMGR_NAME.conf << EOM
[DEFAULTS]
log_file="$LOG_DIR/$NODEMGR_NAME.log"
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
hostip=${hostip}
#contrail_databases=config analytics
#minimum_diskGB=4
#log_category =
db_port=${CASSANDRA_CQL_PORT}
db_jmx_port=${CASSANDRA_JMX_LOCAL_PORT}

[COLLECTOR]
server_list=${COLLECTOR_SERVERS}

$sandesh_client_config
EOM

add_ini_params_from_env ${NODE_TYPE^^}_NODEMGR /etc/contrail/$NODEMGR_NAME.conf

set_vnc_api_lib_ini

/provision.sh

exec "$@"

