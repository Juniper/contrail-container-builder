#!/bin/bash -e

function is_enabled() {
  local val=${1,,}
  [[ "${val}" == 'true' || "${val}" == 'yes' || "${val}" == 'enabled' ]]
}

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
    if server_ip=`perl -MSocket -le 'print inet_ntoa inet_aton shift' $server` \
        && [[ "$local_ips" =~ ",$server_ip," ]] ; then
      my_ip=$server_ip
      my_node=$server_hostname
      echo "INFO: my_ip=$server_ip my_node=$server_hostname"
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
dist_ip=$(echo $my_ip | tr '.' ',')

# copy-paste of common.sh as this file doesn't have access to common.sh
RABBITMQ_NODENAME=contrail@$my_node
RABBITMQ_NODE_PORT=${RABBITMQ_NODE_PORT:-5673}
RABBITMQ_MGMT_PORT=$((RABBITMQ_NODE_PORT+10000))
RABBITMQ_DIST_PORT=$((RABBITMQ_NODE_PORT+20000))
RABBITMQ_HEARTBEAT_INTERVAL=${RABBITMQ_HEARTBEAT_INTERVAL:-10}
RABBITMQ_USER=${RABBITMQ_USER:-'guest'}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:-'guest'}

SERVER_CERTFILE=${SERVER_CERTFILE:-'/etc/contrail/ssl/certs/server.pem'}
SERVER_KEYFILE=${SERVER_KEYFILE:-'/etc/contrail/ssl/private/server-privkey.pem'}
SERVER_CA_CERTFILE=${SERVER_CA_CERTFILE-'/etc/contrail/ssl/certs/ca-cert.pem'}
RABBITMQ_SSL_CERTFILE=${RABBITMQ_SSL_CERTFILE:-${SERVER_CERTFILE}}
RABBITMQ_SSL_KEYFILE=${RABBITMQ_SSL_KEYFILE:-${SERVER_KEYFILE}}
RABBITMQ_SSL_CACERTFILE=${RABBITMQ_SSL_CACERTFILE-${SERVER_CA_CERTFILE}}
RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT=${RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT:-true}

# check ssl settings consistency
if is_enabled $RABBITMQ_USE_SSL ; then
  ssl_dir="/tmp/rabbitmq-ssl/"
  mkdir -p "$ssl_dir"
  for cert in CERTFILE KEYFILE CACERTFILE ; do
    var="RABBITMQ_SSL_${cert}"
    val="${!var}"
    # if val is empty - do not fail
    if [[ -z "$val" ]]; then
      continue
    fi
    if [ ! -f "$val" ] ; then
      echo "ERROR: SSL is requested, but missing required configuration: $var (value is empty or file couldn't be found"
      exit -1
    fi
    # as we know that certs were stored by root then here we will copy them to temporary place and set rabbitmq ownership
    newFile="$ssl_dir/$cert"
    cat "$val" > $newFile
    chown rabbitmq:rabbitmq "$newFile"
    chmod 0400 "$newFile"
    eval 'export '$var'="$newFile"'
  done
fi

# un-export all rabbitmq variables - if entrypoint of rabbitmq founds them then it creates own config and rewrites own
export -n RABBITMQ_NODE_PORT RABBITMQ_DIST_PORT RABBITMQ_DEFAULT_USER RABBITMQ_DEFAULT_PASS RABBITMQ_DEFAULT_VHOST
for name in CACERTFILE CERTFILE KEYFILE DEPTH FAIL_IF_NO_PEER_CERT VERIFY ; do
  export -n RABBITMQ_SSL_$name RABBITMQ_MANAGEMENT_SSL_$name
done

echo "INFO: RABBITMQ_NODENAME=$RABBITMQ_NODENAME, RABBITMQ_NODE_PORT=$RABBITMQ_NODE_PORT"

# to be able to run rabbitmqctl without params
echo "RABBITMQ_NODENAME=contrail@$my_node" > /etc/rabbitmq/rabbitmq-env.conf
if is_enabled $RABBITMQ_USE_SSL ; then
  echo 'RABBITMQ_CTL_ERL_ARGS="-proto_dist inet_tls"' >> /etc/rabbitmq/rabbitmq-env.conf
fi

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
if is_enabled $RABBITMQ_USE_SSL ; then
  cat << EOF > /etc/rabbitmq/rabbitmq.config
[
   {rabbit, [ {tcp_listeners, [ ]},
              {ssl_listeners, [{"${my_ip}", ${RABBITMQ_NODE_PORT}}]},
              {ssl_options,
                        [{cacertfile, "${RABBITMQ_SSL_CACERTFILE}"},
                         {certfile, "${RABBITMQ_SSL_CERTFILE}"},
                         {keyfile, "${RABBITMQ_SSL_KEYFILE}"},
                         {verify, verify_peer},
                         {fail_if_no_peer_cert, ${RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT}}]
              },
EOF
else
  cat << EOF > /etc/rabbitmq/rabbitmq.config
[
   {rabbit, [ {tcp_listeners, [{"${my_ip}", ${RABBITMQ_NODE_PORT}}]},
              {ssl_listeners, [ ]},
EOF
fi
cat << EOF >> /etc/rabbitmq/rabbitmq.config
              {cluster_partition_handling, autoheal},
              {loopback_users, []},
              {cluster_nodes, {[${cluster_nodes::-1}], disc}},
              {vm_memory_high_watermark, 0.8},
              {disk_free_limit,50000000},
              {log_levels,[{connection, info},{mirroring, info}]},
              {heartbeat, ${RABBITMQ_HEARTBEAT_INTERVAL}},
              {delegate_count,20},
              {channel_max,5000},
              {tcp_listen_options,
                        [{backlog, 128},
                         {nodelay, true},
                         {exit_on_close, false},
                         {keepalive, true}]
              },
              {collect_statistics_interval, 60000},
              {default_user, <<"${RABBITMQ_USER}">>},
              {default_pass, <<"${RABBITMQ_PASSWORD}">>}
            ]
   },
   {rabbitmq_management, [{listener, [{port, ${RABBITMQ_MGMT_PORT}}]}]},
   {rabbitmq_management_agent, [ {force_fine_statistics, true} ] },
   {kernel, [{net_ticktime,  60}, {inet_dist_use_interface, {${dist_ip}}}, {inet_dist_listen_min, ${RABBITMQ_DIST_PORT}}, {inet_dist_listen_max, ${RABBITMQ_DIST_PORT}}]}
].
EOF

# copy-paste from base container because there is no way to reach this blocks of code there
if is_enabled $RABBITMQ_USE_SSL && [[ "$1" == rabbitmq* ]]; then
  combinedSsl="$ssl_dir/combined.pem"
  # Create combined cert
  cat "$RABBITMQ_SSL_CERTFILE" "$RABBITMQ_SSL_KEYFILE" > "$combinedSsl"
  chown rabbitmq:rabbitmq "$combinedSsl"
  chmod 0400 "$combinedSsl"
  # More ENV vars for make clustering happiness
  # we don't handle clustering in this script, but these args should ensure
  # clustered SSL-enabled members will talk nicely
  export ERL_SSL_PATH="$(erl -eval 'io:format("~p", [code:lib_dir(ssl, ebin)]),halt().' -noshell)"
  sslErlArgs="-pa $ERL_SSL_PATH -proto_dist inet_tls -ssl_dist_opt server_certfile $combinedSsl -ssl_dist_opt server_secure_renegotiate true client_secure_renegotiate true"
  export RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="${RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS:-} $sslErlArgs"
  export RABBITMQ_CTL_ERL_ARGS="${RABBITMQ_CTL_ERL_ARGS:-} $sslErlArgs"
fi

echo "INFO: $(date): /docker-entrypoint.sh $@"
exec /docker-entrypoint.sh "$@"
