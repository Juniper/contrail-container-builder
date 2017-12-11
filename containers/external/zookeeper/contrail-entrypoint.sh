#!/bin/bash -e

ord=1
IFS=',' read -ra srv_list <<< "$ZOOKEEPER_NODES"
local_ips=$(ip addr | awk '/inet/ {print($2)}')
for srv in "${srv_list[@]}"; do
  if [[ "$local_ips" =~ "$srv" ]] ; then
    echo "INFO: found '$srv' in local IPs '$local_ips'"
    break
  fi
  ord=$((ord+1))
done

if (( $ord < 1 || $ord > "${#srv_list[@]}" )); then
  echo "ERROR: Cannot find self ips ('$local_ips') in Zookeeper nodes ('$ZOOKEEPER_NODES')"
  exit
fi

export ZOO_MY_ID=$ord
exec "$@"