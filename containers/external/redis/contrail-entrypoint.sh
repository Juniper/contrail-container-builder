#!/bin/bash -e

REDIS_NODES=${REDIS_NODES:-${ANALYTICS_NODES:-${CONTROLLER_NODES}}}
# redis is needed for WebUI also. WebUI works with 127.0.0.1
# If WebUI is placed on the same node with analytics - redis will listen on two IP-s and analytics and WebUI will work well.
# If WebUI is placed on different node than analitics - redis on the node with WebUI will listen only 127.0.0.1 and it is sufficient for WebUI.

REDIS_SERVER_PORT=${REDIS_SERVER_PORT:-6379}
REDIS_LISTEN_ADDRESS=${REDIS_LISTEN_ADDRESS:-}
REDIS_SERVER_PASSWORD=${REDIS_SERVER_PASSWORD:-}
REDIS_PROTECTED_MODE=${REDIS_PROTECTED_MODE:-}

if [[ -z "$REDIS_LISTEN_ADDRESS" && -n "$REDIS_NODES" ]]; then
  for i in {1..10} ; do
    ord=1
    my_ord=0
    IFS=',' read -ra srv_list <<< "$REDIS_NODES"
    local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"
    redis_servers=''
    for srv in "${srv_list[@]}"; do
      if srv_ip=`perl -MSocket -le 'print inet_ntoa inet_aton shift' $srv` \
          && [[ "$local_ips" =~ ",$srv_ip," ]] ; then
        redis_node_ip=${srv_ip}
        echo "INFO: found '$srv/$srv_ip' in local IPs '$local_ips'"
        my_ord=$ord
      fi
      ord=$((ord+1))
    done
    if (( $my_ord > 0 && $my_ord <= "${#srv_list[@]}" )); then
      break
    fi
    sleep 1
  done
  [ -n "$redis_node_ip" ] && REDIS_LISTEN_ADDRESS=${redis_node_ip}
fi

redis_opts="--lua-time-limit 15000"
redis_opts+=" --dbfilename ''"
redis_opts+=' --bind 127.0.0.1'
[ -n "$REDIS_LISTEN_ADDRESS" ] && redis_opts+=" $REDIS_LISTEN_ADDRESS"
[ -n "$REDIS_SERVER_PORT" ] && redis_opts+=" --port $REDIS_SERVER_PORT"
[ -n "$REDIS_SERVER_PASSWORD" ] && redis_opts+=" --requirepass $REDIS_SERVER_PASSWORD"
[ -n "$REDIS_PROTECTED_MODE" ] && redis_opts+=" --protected-mode $REDIS_PROTECTED_MODE"

echo "INFO: redis cmd options: $redis_opts"
exec docker-entrypoint.sh $redis_opts
