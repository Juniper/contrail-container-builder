#!/bin/bash -e

REDIS_PORT=${REDIS_PORT:-6379}

if [[ -n $REDIS_NODES ]]; then
  for i in {1..10} ; do
    ord=1
    my_ord=0
    IFS=',' read -ra srv_list <<< "$REDIS_NODES"
    local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"
    redis_servers=''
    for srv in "${srv_list[@]}"; do
      if [[ "$local_ips" =~ ",$srv," ]] ; then
         redis_node_ip=${srv}
        echo "INFO: found '$srv' in local IPs '$local_ips'"
        my_ord=$ord
      fi
      ord=$((ord+1))
    done
    if (( $my_ord > 0 && $my_ord <= "${#srv_list[@]}" )); then
      break
    fi
    sleep 1
  done
fi

REDIS_LISTEN_ADDRESS=${REDIS_LISTEN_ADDRESS:-${redis_node_ip}}

if [[ -n "$REDIS_LISTEN_ADDRESS" ]] ; then
  redis_opts+="--bind \"$REDIS_LISTEN_ADDRESS 127.0.0.1\""
fi
if [[ -n "$REDIS_PORT" ]] ; then
  redis_opts+=" --port $REDIS_PORT"
fi
redis_opts+=" --lua-time-limit 15000"
redis_opts+=" --dbfilename ''"
if [[ -n "$REDIS_SERVER_PASSWORD" ]] ; then
  redis_opts+=" --requirepass $REDIS_SERVER_PASSWORD"
fi
exec /docker-entrypoint.sh $redis_opts
