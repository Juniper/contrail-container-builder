#!/bin/bash

source /common.sh

pre_start_init

# Env variables:
# NODE_TYPE = name of the component [vrouter, config, control, analytics, database, config-database, toragent]

set_vnc_api_lib_ini

if is_enabled ${MAINTENANCE_MODE} ; then
  echo "WARNING: MAINTENANCE_MODE is switched on - provision.sh is not called."
elif ! /provision.sh ; then
  echo "ERROR: provision.sh was failed. Exiting..."
  exit 1
fi

if [[ $NODE_TYPE == 'toragent' ]]; then
  # we don't have support of this node_type in nodemgr itself.
  exit 0
fi

# ToDo - decide how to resolve this for non-contrail parts
export NODEMGR_TYPE=contrail-${NODE_TYPE}
NODEMGR_NAME=${NODEMGR_TYPE}-nodemgr

ntype=`echo ${NODE_TYPE^^} | tr '-' '_'`

if [[ $ntype == 'VROUTER' ]]; then
  htype='VROUTER'
  hostip=$(get_ip_for_vrouter_from_control)
  host_name=${VROUTER_HOSTNAME:-}
else
  # nodes list var name is a ANALYTICSDB_NODES (not DATABASE_NODES)
  if [[ $ntype == 'DATABASE' ]] ; then
    htype='ANALYTICSDB'
  elif [[ $ntype == 'CONFIG_DATABASE' ]] ; then
    htype='CONFIGDB'
  else
    htype="$ntype"
  fi

  hostip=$(get_listen_ip_for_node ${htype})
fi

introspect_ip='0.0.0.0'
if ! is_enabled ${INTROSPECT_LISTEN_ALL} ; then
  introspect_ip=$hostip
fi

cat > /etc/contrail/$NODEMGR_NAME.conf << EOM
[DEFAULTS]
http_server_ip=$introspect_ip
log_file=$LOG_DIR/$NODEMGR_NAME.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
hostip=${hostip}
db_port=${CASSANDRA_CQL_PORT}
db_jmx_port=${CASSANDRA_JMX_LOCAL_PORT}
db_use_ssl=$(format_boolean $CASSANDRA_SSL_ENABLE)
EOM

if [ -n "${host_name}" ]; then
cat >> /etc/contrail/$NODEMGR_NAME.conf << EOM
hostname=${host_name}
EOM
fi

cat >> /etc/contrail/$NODEMGR_NAME.conf << EOM

[COLLECTOR]
server_list=${COLLECTOR_SERVERS}

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env ${ntype}_NODEMGR /etc/contrail/$NODEMGR_NAME.conf

cat /etc/contrail/$NODEMGR_NAME.conf

exec "$@"
