#!/bin/bash -e

ord=1
IFS=',' read -ra srv_list <<< "$ZOOKEEPER_NODES"
local_ips=$(ip addr | awk '/inet/ {print($2)}')
zoo_servers=''
for srv in "${srv_list[@]}"; do
  if [[ -z "$ZOO_SERVERS" && -n "$ZOOKEEPER_PORTS" ]] ; then
    zoo_servers+="server.${ord}=${srv}:${ZOOKEEPER_PORTS} "
  fi
  ord=$((ord+1))
done
for srv in "${srv_list[@]}"; do
  if [[ "$local_ips" =~ "$srv" ]] ; then
    echo "INFO: found '$srv' in local IPs '$local_ips'"
    my_ip=$srv
    break
  fi
done

if [ -z "$my_ip" ]; then
  echo "ERROR: Cannot find self ips ('$local_ips') in Zookeeper nodes ('$ZOOKEEPER_NODES')"
  exit
fi

# If ZOO_SERVERS is provided then just use it, because it is an interface of
# the inherited zookeeper container, else define it in case if
# custome zookeeper ports are provided.
if [[ "$zoo_servers" != '' ]] ; then
  export ZOO_SERVERS=${zoo_servers::-1}
fi
export ZOO_PORT=${ZOOKEEPER_PORT}
export ZOO_MY_ID=$ord

echo "INFO: ZOO_MY_ID=$ZOO_MY_ID"
echo "INFO: ZOO_SERVERS=$ZOO_SERVERS"
echo "INFO: /docker-entrypoint.sh $@"

exec /docker-entrypoint.sh "$@"
