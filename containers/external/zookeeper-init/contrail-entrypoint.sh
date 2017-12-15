#!/bin/bash -e

ord=1
my_ord=0
IFS=',' read -ra srv_list <<< "$ZOOKEEPER_NODES"
local_ips=$(ip addr | awk '/inet/ {print($2)}')
zoo_servers=''
for srv in "${srv_list[@]}"; do
  if [[ -z "$ZOO_SERVERS" && -n "$ZOOKEEPER_PORTS" ]] ; then
    zoo_servers+="server.${ord}=${srv}:${ZOOKEEPER_PORTS} "
  fi
  if [[ "$local_ips" =~ "$srv" ]] ; then
    echo "INFO: found '$srv' in local IPs '$local_ips'"
    my_ord=$ord
  fi
  ord=$((ord+1))
done

if (( $my_ord < 1 || $my_ord > "${#srv_list[@]}" )); then
  echo "ERROR: Cannot find self ips ('$local_ips') in Zookeeper nodes ('$ZOOKEEPER_NODES')"
  exit
fi

# If ZOO_SERVERS is provided then just use it, because it is an interface of
# the inherited zookeeper container, else define it in case if
# custome zookeeper ports are provided.
if [[ "$zoo_servers" != '' ]] ; then
  export ZOO_SERVERS=${zoo_servers::-1}
fi

export ZOO_MY_ID=$my_ord

echo "INFO: ZOO_MY_ID=$ZOO_MY_ID"
echo "INFO: ZOO_SERVERS=$ZOO_SERVERS"
echo "INFO: /docker-entrypoint.sh $@"

exec /docker-entrypoint.sh "$@"