#!/bin/bash
#set -e
source /common.sh

hostip=$(get_listen_ip_for_node ANALYTICSDB)
DEFAULT_LOCAL_IP=${DEFAULT_LOCAL_IP:-'0.0.0.0'}
: ${CASSANDRA_RPC_ADDRESS=${CASSANDRA_RPC_ADDRESS:-$DEFAULT_LOCAL_IP}}

: ${CASSANDRA_LISTEN_ADDRESS='auto'}
if [ "$CASSANDRA_LISTEN_ADDRESS" = 'auto' ]; then
	CASSANDRA_LISTEN_ADDRESS=${DEFAULT_LOCAL_IP}
fi

: ${CASSANDRA_BROADCAST_ADDRESS="$CASSANDRA_LISTEN_ADDRESS"}

if [ "$CASSANDRA_BROADCAST_ADDRESS" = 'auto' ]; then
	CASSANDRA_BROADCAST_ADDRESS="$(hostname --ip-address)"
fi
: ${CASSANDRA_BROADCAST_RPC_ADDRESS:=$CASSANDRA_BROADCAST_ADDRESS}

if [ -n "${CASSANDRA_NAME:+1}" ]; then
	: ${CASSANDRA_SEEDS:="cassandra"}
fi
IFS=',' read -ra server_list <<< "${CONTROLLER_NODES}"
: ${CASSANDRA_SEEDS:="${server_list[0]}"}

sed -ri 's/(- seeds:).*/\1 "'"$CASSANDRA_SEEDS"'"/' "$CASSANDRA_CONFIG/cassandra.yaml"

for yaml in \
	broadcast_address \
	broadcast_rpc_address \
	cluster_name \
	endpoint_snitch \
	listen_address \
	num_tokens \
	rpc_address \
	start_rpc \
; do
	var="CASSANDRA_${yaml^^}"
	val="${!var}"
	if [ "$val" ]; then
		sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "$CASSANDRA_CONFIG/cassandra.yaml"
	fi
done

for rackdc in dc rack; do
	var="CASSANDRA_${rackdc^^}"
	val="${!var}"
	if [ "$val" ]; then
		sed -ri 's/^('"$rackdc"'=).*/\1 '"$val"'/' "$CASSANDRA_CONFIG/cassandra-rackdc.properties"
	fi
done
export JVM_EXTRA_OPTS="-Dcassandra.rpc_port=${CONFIGDB_PORT:-9161} \
  -Dcassandra.native_transport_port=${CONFIGDB_CQL_PORT:-9041} \
  -Dcassandra.ssl_storage_port=${CONFIGDB_SSL_STORAGE_PORT:-7013} \
  -Dcassandra.storage_port=${CONFIGDB_STORAGE_PORT:-7012} \
  -Dcassandra.jmx.local.port=${CONFIGDB_JMX_LOCAL_PORT:-7201} \
  -Xms1g -Xmx2g"

exec "$@"
