#!/bin/bash -e

# In all in one deployment there is the race between vhost0 initialization
# and own IP detection, so there is 10 retries
for i in {1..10} ; do
  server_names_list=()
  cluster_nodes=''
  local_ips=",$(cat "/proc/net/fib_trie" | awk '/32 host/ { print f } {f=$2}' | tr '\n' ','),"
  IFS=',' read -ra server_list <<< "${RABBITMQ_NODES}"
  my_ip=''
  my_node=''
  rabbit_node_list=''
  for server in ${server_list[@]}; do
    server_hostname=''
    if getent hosts $server ; then
      server_hostname=$(getent hosts $server | awk '{print $2}' | awk -F '.' '{print $1}')
    else
      if host -4 $server ; then
        server_hostname=$(host -4 $server | cut -d" " -f5 | awk '{print $1}')
        server_hostname=${server_hostname::-1}
      fi
    fi
    if [[ "$server_hostname" == '' ]] ; then
      echo "WARNING: hostname for $server is not resolved properly, cluster setup will not be functional."
    fi
    cluster_nodes+="'contrail@${server_hostname}',"
    server_names_list=($server_names_list $server_hostname)
    if [[ "$local_ips" =~ ",$server," ]] ; then
      my_ip=$server
      my_node=$server_hostname
      echo "INFO: my_ip=$server my_node=$server_hostname"
    fi
  done
  if [ -n "$my_ip" ] ; then
    break
  fi
  sleep 1
done

if [ -z "$my_ip" ] ; then
  echo "ERROR: Cannot find self ips ('$local_ips') in RabbitMQ nodes ('$RABBITMQ_NODES')"
  exit -1
fi

RABBITMQ_NODENAME=contrail@$my_node
RABBITMQ_NODE_PORT=${RABBITMQ_NODE_PORT:-5673}


echo "INFO: RABBITMQ_NODENAME=$RABBITMQ_NODENAME, RABBITMQ_NODE_PORT=$RABBITMQ_NODE_PORT"

# to be able to run rabbitmqctl without params
echo "RABBITMQ_NODENAME=contrail@$my_node" > /etc/rabbitmq/rabbitmq-env.conf

# save cookie to file (otherwise rabbitmqctl set it to wrong value)
if [[ -n "$RABBITMQ_ERLANG_COOKIE" ]] ; then
  cookie_file="/var/lib/rabbitmq/.erlang.cookie"
  echo $RABBITMQ_ERLANG_COOKIE > $cookie_file
  chmod 600 $cookie_file
  chown rabbitmq:rabbitmq $cookie_file
fi

# It looks that there is a race in rabbitmq auto-cluster discovery that
# leads to a split-brain on cluster start and cluster is setup
# incorrectly - some of nodes decide to form own cluster instead to join to others.
if [[ "${server_names_list[0]}" != "$my_node" ]] ; then
  echo "INFO: delay node $my_node start until first node starts: ${i}/10..."
  for i in {1..20} ; do
    sleep 3
    echo "INFO: check if the node contrail@${server_names_list[0]} started: ${i}/20..."
    if rabbitmqctl -q -n contrail@${server_names_list[0]} cluster_status ; then
      break
    fi
  done
fi

cat << EOF > /etc/rabbitmq/rabbitmq.config
[
   {rabbit, [ {tcp_listeners, [{"${my_ip}", ${RABBITMQ_NODE_PORT}}]}, {cluster_partition_handling, autoheal},{loopback_users, []},
              {cluster_nodes, {[${cluster_nodes::-1}], disc}},
              {vm_memory_high_watermark, 0.8},
              {disk_free_limit,50000000},
              {log_levels,[{connection, info},{mirroring, info}]},
              {heartbeat,10},
              {delegate_count,20},
              {channel_max,5000},
              {tcp_listen_options,
                        [binary,
                          {packet, raw},
                          {reuseaddr, true},
                          {backlog, 128},
                          {nodelay, true},
                          {exit_on_close, false},
                          {keepalive, true}
                         ]
              },
              {collect_statistics_interval, 60000}
            ]
   },
   {rabbitmq_management_agent, [ {force_fine_statistics, true} ] },
   {kernel, [{net_ticktime,  60}]}
].
EOF

echo "INFO: $(date): /docker-entrypoint.sh $@"
exec /docker-entrypoint.sh "$@"
