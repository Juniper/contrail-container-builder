#!/bin/bash -e

IFS=',' read -ra srv_list <<< "$CASSANDRA_SEEDS"
local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"
for srv in "${srv_list[@]}"; do
  if [[ "$local_ips" =~ ",$srv," ]] ; then
    echo "INFO: found '$srv' in local IPs '$local_ips'"
    my_ip=$srv
    break
  fi
done

if [ -z "$my_ip" ]; then
  echo "ERROR: Cannot find self ips ('$local_ips') in Cassandra nodes ('$CASSANDRA_SEEDS')"
  exit 0
fi

if ! nodetool status -p "$CASSANDRA_JMX_LOCAL_PORT" | grep -E "^UN\\s+$my_ip"; then
  echo "ERROR: Nodetool status: "
  echo "$(nodetool status -p $CASSANDRA_JMX_LOCAL_PORT)"
  exit 1
fi
