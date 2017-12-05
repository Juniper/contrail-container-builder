#!/bin/bash
set -e

default_interface=`ip route show |grep "default via" |awk '{print $5}'`
default_ip_address=`ip address show dev $default_interface |head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
: ${CASSANDRA_RPC_ADDRESS='0.0.0.0'}

: ${CASSANDRA_LISTEN_ADDRESS='auto'}
if [ "$CASSANDRA_LISTEN_ADDRESS" = 'auto' ]; then
	CASSANDRA_LISTEN_ADDRESS=${default_ip_address}
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
export JVM_EXTRA_OPTS="-Dcassandra.rpc_port=${ANALYTICSDB_PORT:-9160} \
  -Dcassandra.native_transport_port=${ANALYTICSDB_CQL_PORT:-9042} \
  -Dcassandra.ssl_storage_port=${ANALYTICSDB_SSL_STORAGE_PORT:-7011} \
  -Dcassandra.storage_port=${ANALYTICSDB_STORAGE_PORT:-7010} \
  -Dcassandra.jmx.local.port=${ANALYTICSDB_JMX_LOCAL_PORT:-7200} \
  -Xms1g -Xmx2g"

exec "$@"
