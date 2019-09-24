#!/bin/bash -e

source /common.sh

# In all in one deployment there is the race between vhost0 initialization
# and own IP detection, so there is 10 retries
for i in {1..10} ; do
  my_ip_and_order=$(find_my_ip_and_order_for_node ZOOKEEPER)
  if [ -n "$my_ip_and_order" ]; then
    break
  fi
  sleep 1
done
if [ -z "$my_ip_and_order" ]; then
  echo "ERROR: Cannot find self ips ('$(get_local_ips)') in Zookeeper nodes ('$ZOOKEEPER_NODES')"
  exit -1
fi
export MY_ZOO_IP=$(echo $my_ip_and_order | cut -d ' ' -f 1)
my_ord=$(echo $my_ip_and_order | cut -d ' ' -f 2)

# If ZOO_SERVERS is provided then just use it, because it is an interface of
# the inherited zookeeper container, else define it in case if
# custome zookeeper ports are provided.
if [[ -z "$ZOO_SERVERS" ]] ; then
  ord=1
  for srv in $(echo $ZOOKEEPER_NODES | tr ',' ' '); do
    zoo_servers+="server.${ord}=${srv}:${ZOOKEEPER_PORTS} "
    ord=$((ord+1))
  done
  export ZOO_SERVERS=${zoo_servers::-1}
fi

export ZOO_PORT=${ZOOKEEPER_PORT}
export ZOO_MY_ID=$my_ord

echo "INFO: ZOO_MY_ID=$ZOO_MY_ID, ZOO_PORT=$ZOO_PORT"
echo "INFO: ZOO_SERVERS=$ZOO_SERVERS"
echo "INFO: /docker-entrypoint.sh $@"

# Zookeeper has a check to validate dataDir and dataLogDir parameters at startup
# if they are different. So, keeping them same. Details - CEM-9153, CEM-9150
export ZOO_DATA_DIR=${CONTRAIL_ZOOKEEPER_DATA:-'/data'}
export ZOO_DATA_LOG_DIR=${CONTRAIL_ZOOKEEPER_DATALOG:-'/data'}

# Generate the config file
CONFIG="$ZOO_CONF_DIR/zoo.cfg"

cat > ${CONFIG} << EOM
clientPort=${ZOO_PORT}
clientPortAddress=${MY_ZOO_IP}
dataDir=${ZOO_DATA_DIR}
dataLogDir=${ZOO_DATA_LOG_DIR}

tickTime=${ZOO_TICK_TIME}
initLimit=${ZOO_INIT_LIMIT}
syncLimit=${ZOO_SYNC_LIMIT}

maxClientCnxns=${ZOO_MAX_CLIENT_CNXNS}
EOM

for server in $ZOO_SERVERS; do
    echo "$server" >> "$CONFIG"
done

exec /docker-entrypoint.sh "$@"
