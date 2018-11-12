#!/bin/bash -e

ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
ZOOKEEPER_PORTS=${ZOOKEEPER_PORTS:-'2888:3888'}
MY_ZOO_IP="0.0.0.0"

# In all in one deployment there is the race between vhost0 initialization
# and own IP detection, so there is 10 retries
for i in {1..10} ; do
  ord=1
  my_ord=0
  IFS=',' read -ra srv_list <<< "$ZOOKEEPER_NODES"
  local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"
  zoo_servers=''
  for srv in "${srv_list[@]}"; do
    if [[ -z "$ZOO_SERVERS" ]] ; then
      zoo_servers+="server.${ord}=${srv}:${ZOOKEEPER_PORTS} "
    fi
    if [[ "$local_ips" =~ ",$srv," ]] ; then
      echo "INFO: found '$srv' in local IPs '$local_ips'"
      export MY_ZOO_IP=${srv}
      my_ord=$ord
    fi
    ord=$((ord+1))
  done
  if (( $my_ord > 0 && $my_ord <= "${#srv_list[@]}" )); then
    break
  fi
  sleep 1
done

if (( $my_ord < 1 || $my_ord > "${#srv_list[@]}" )); then
  echo "ERROR: Cannot find self ips ('$local_ips') in Zookeeper nodes ('$ZOOKEEPER_NODES')"
  exit -1
fi

# If ZOO_SERVERS is provided then just use it, because it is an interface of
# the inherited zookeeper container, else define it in case if
# custome zookeeper ports are provided.
if [[ "$zoo_servers" != '' ]] ; then
  export ZOO_SERVERS=${zoo_servers::-1}
fi

export ZOO_PORT=${ZOOKEEPER_PORT}
export ZOO_MY_ID=$my_ord

echo "INFO: ZOO_MY_ID=$ZOO_MY_ID, ZOO_PORT=$ZOO_PORT"
echo "INFO: ZOO_SERVERS=$ZOO_SERVERS"
echo "INFO: /docker-entrypoint.sh $@"

# Generate the config only if it doesn't exist
if [[ ! -f "$ZOO_CONF_DIR/zoo.cfg" ]]; then
    CONFIG="$ZOO_CONF_DIR/zoo.cfg"

    echo "clientPort=$ZOO_PORT" >> "$CONFIG"
    if [[ $MY_ZOO_IP != '0.0.0.0' ]] ; then
      echo "clientPortAddress=$MY_ZOO_IP" >> "$CONFIG"
    fi
    echo "dataDir=$ZOO_DATA_DIR" >> "$CONFIG"
    echo "dataLogDir=$ZOO_DATA_LOG_DIR" >> "$CONFIG"

    echo "tickTime=$ZOO_TICK_TIME" >> "$CONFIG"
    echo "initLimit=$ZOO_INIT_LIMIT" >> "$CONFIG"
    echo "syncLimit=$ZOO_SYNC_LIMIT" >> "$CONFIG"

    echo "maxClientCnxns=$ZOO_MAX_CLIENT_CNXNS" >> "$CONFIG"

    for server in $ZOO_SERVERS; do
        echo "$server" >> "$CONFIG"
    done
fi

exec /docker-entrypoint.sh "$@"
