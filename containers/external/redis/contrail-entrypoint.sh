#!/bin/bash -e

# In all in one deployment there is the race between vhost0 initialization
# and own IP detection, so there is 10 retries
for i in {1..10} ; do
  host_ip=''
  IFS=',' read -ra srv_list <<< "$ANALYTICS_NODES"
  local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"
  for srv in "${srv_list[@]}"; do
    if [[ "$local_ips" =~ ",$srv," ]] ; then
      echo "INFO: found '$srv' in local IPs '$local_ips'"
      host_ip=$srv
      break
    fi
  done
  if [ -n "$host_ip" ]; then
    break
  fi
  sleep 1
done
redis_opts="--bind $host_ip 127.0.0.1"
redis_opts+=" --lua-time-limit 15000"
redis_opts+=" --dbfilename ''"
if [[ -n "$REDIS_SERVER_PASSWORD" ]] ; then
  redis_opts+=" --requirepass $REDIS_SERVER_PASSWORD"
fi
redis-server $redis_opts
