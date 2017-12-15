#!/bin/bash -e

IFS=',' read -ra srv_list <<< "$CASSANDRA_SEEDS"
local_ips=$(ip addr | awk '/inet/ {print($2)}')
for srv in "${srv_list[@]}"; do
  if [[ "$local_ips" =~ "$srv" ]] ; then
    echo "INFO: found '$srv' in local IPs '$local_ips'"
    my_ip=$srv
    break
  fi
done

if [ -z "$my_ip" ]; then
  echo "ERROR: Cannot find self ips ('$local_ips') in Cassandra nodes ('$CASSANDRA_SEEDS')"
  exit
fi

# use first two servers as seeds
export CASSANDRA_SEEDS=$(echo $CASSANDRA_SEEDS | cut -d ',' -f 1,2)
export CASSANDRA_LISTEN_ADDRESS=$my_ip

export JVM_EXTRA_OPTS="-Dcassandra.rpc_port=${CASSANDRA_PORT:-9160} \
  -Dcassandra.native_transport_port=${CASSANDRA_CQL_PORT:-9042} \
  -Dcassandra.ssl_storage_port=${CASSANDRA_SSL_STORAGE_PORT:-7011} \
  -Dcassandra.storage_port=${CASSANDRA_STORAGE_PORT:-7010} \
  -Dcassandra.jmx.local.port=${CASSANDRA_JMX_LOCAL_PORT:-7200} \
  -Xms1g -Xmx2g"

echo "INFO: CASSANDRA_SEEDS=$CASSANDRA_SEEDS CASSANDRA_LISTEN_ADDRESS=$CASSANDRA_LISTEN_ADDRESS"
echo "INFO: exec /docker-entrypoint.sh $@"

exec /docker-entrypoint.sh "$@"
