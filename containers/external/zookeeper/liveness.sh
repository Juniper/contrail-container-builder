#!/bin/bash -e

IFS=',' read -ra srv_list <<< "$ZOOKEEPER_NODES"
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
  exit 1
fi

OK=$(echo ruok | nc $my_ip $ZOOKEEPER_PORT)
if [ "$OK" == "imok" ]; then
    exit 0
else
    exit 1
fi
