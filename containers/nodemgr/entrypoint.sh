#!/bin/bash

source /common.sh

pre_start_init

# Env variables:
# NODE_TYPE = name of the component [vrouter, config, control, analytics, database, config-database]

# ToDo - decide how to resolve this for non-contrail parts
export NODEMGR_TYPE=contrail-${NODE_TYPE}
NODEMGR_NAME=${NODEMGR_TYPE}-nodemgr

ntype=`echo ${NODE_TYPE^^} | tr '-' '_'`
hostip=$(get_listen_ip_for_node ${ntype})

cat > /etc/contrail/$NODEMGR_NAME.conf << EOM
[DEFAULTS]
log_file=$LOG_DIR/$NODEMGR_NAME.log
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

add_ini_params_from_env ${ntype}_NODEMGR /etc/contrail/$NODEMGR_NAME.conf

set_vnc_api_lib_ini

if [[ ${MAINTENANCE_MODE^^} == 'TRUE' ]]; then
  echo "WARNING: MAINTENANCE_MODE is switched on - provision.sh is not called."
elif ! /provision.sh ; then
  echo "ERROR: provision.sh was failed. Exiting..."
  exit 1
fi

exec "$@"

