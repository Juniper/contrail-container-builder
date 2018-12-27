#!/bin/bash -e

source /common.sh

pre_start_init

# In all in one deployment there is the race between vhost0 initialization
# and own IP detection, so there is 10 retries
for i in {1..10} ; do
  my_ip=$(find_my_ip_and_order_for_node_list "$CASSANDRA_SEEDS" | cut -d ' ' -f 1)
  if [ -n "$my_ip" ]; then
    break
  fi
  sleep 1
done

if [ -z "$my_ip" ]; then
  echo "ERROR: Cannot find self ips ('$(get_local_ips)') in Cassandra nodes ('$CASSANDRA_SEEDS')"
  exit -1
fi

# use first two servers as seeds
export CASSANDRA_SEEDS=$(echo $CASSANDRA_SEEDS | cut -d ',' -f 1,2)
export CASSANDRA_LISTEN_ADDRESS=$my_ip
export CASSANDRA_RPC_ADDRESS=$my_ip

export JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Dcassandra.rpc_port=${CASSANDRA_PORT} \
  -Dcassandra.native_transport_port=${CASSANDRA_CQL_PORT} \
  -Dcassandra.ssl_storage_port=${CASSANDRA_SSL_STORAGE_PORT} \
  -Dcassandra.storage_port=${CASSANDRA_STORAGE_PORT} \
  -Dcassandra.jmx.local.port=${CASSANDRA_JMX_LOCAL_PORT}"

echo "INFO: CASSANDRA_SEEDS=$CASSANDRA_SEEDS CASSANDRA_LISTEN_ADDRESS=$CASSANDRA_LISTEN_ADDRESS JVM_EXTRA_OPTS=$JVM_EXTRA_OPTS"
echo "INFO: exec /docker-entrypoint.sh $@"

exec /docker-entrypoint.sh "$@"
