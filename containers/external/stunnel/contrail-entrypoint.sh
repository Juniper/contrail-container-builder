#!/bin/bash -e

source /common.sh

pre_start_init
wait_redis_certs_if_ssl_enabled

STUNNEL_CONF_DIR=/etc/stunnel
STUNNEL_PID_DIR=/var/run/stunnel

STUNNEL_CONF_FILE=$STUNNEL_CONF_DIR/stunnel.conf
STUNNEL_CERT_FILE=$STUNNEL_CONF_DIR/private.pem

mkdir -p $STUNNEL_PID_DIR $STUNNEL_CONF_DIR

# We need to combine key and certificate into a single file for stunnel to use and change file permission
cat $REDIS_SSL_KEYFILE $REDIS_SSL_CERTFILE > $STUNNEL_CERT_FILE
chmod 600 $STUNNEL_CERT_FILE

user_opts=''
if [[ -n "$CONTRAIL_UID" && -n "$CONTRAIL_GID" ]] ; then
  read -r -d '' user_opts << EOM || true
setuid = $CONTRAIL_UID
setgid = $CONTRAIL_GID
EOM
fi

# it doesn't matter here if REDIS_NODES will have duplicates
# first list must be ANALYTICSNODES and if IP can be found there then it doesn't matter
# what is in WEBUI_NODES
REDIS_NODES="${REDIS_NODES:-$ANALYTICS_NODES,$WEBUI_NODES}"

# Stunnel should listen on 2 ip address - my_ip and localhost
if [[ -z "$REDIS_LISTEN_ADDRESS" && -n "$REDIS_NODES" ]]; then
  for i in {1..10} ; do
    my_ip_and_order=$(find_my_ip_and_order_for_node REDIS)
    if [ -n "$my_ip_and_order" ]; then
      break
    fi
    sleep 1
  done
  if [ -z "$my_ip_and_order" ]; then
    echo "ERROR: Cannot find self ips ('$(get_local_ips)') in Redis nodes ('$REDIS_NODES')"
    exit -1
  fi
  redis_node_ip=$(echo $my_ip_and_order | cut -d ' ' -f 1)
  [ -n "$redis_node_ip" ] && REDIS_LISTEN_ADDRESS=${redis_node_ip}
fi

# Populating stunnel.conf file
cat > $STUNNEL_CONF_FILE << EOM
$user_opts
cert = $STUNNEL_CERT_FILE
pid = $STUNNEL_PID_DIR/stunnel.pid
sslVersion = TLSv1.2
foreground = yes
[redis]
accept = $REDIS_LISTEN_ADDRESS:$REDIS_SERVER_PORT
connect = 127.0.0.1:$REDIS_SERVER_PORT
EOM

if [[ -n "$CONTRAIL_UID" && -n "$CONTRAIL_GID" ]] ; then
  chown -R $CONTRAIL_UID:$CONTRAIL_GID $STUNNEL_PID_DIR $STUNNEL_CONF_DIR
fi

exec "$@"
