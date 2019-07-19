#!/bin/bash -e

source /common.sh

pre_start_init
wait_redis_certs_if_ssl_enabled

STUNNEL_CONF_FILE=/etc/stunnel/stunnel.conf
STUNNEL_CERT_FILE=/etc/stunnel/private.pem

# We need to combine key and certificate into a single file for stunnel to use and change file permission
cat $REDIS_SSL_KEYFILE $REDIS_SSL_CERTFILE > $STUNNEL_CERT_FILE
chmod 644 $STUNNEL_CERT_FILE

user_opts=''
if [[ -n "$CONTRAIL_UID" && -n "$CONTRAIL_GID" ]] ; then
  chown $CONTRAIL_UID:$CONTRAIL_GID $STUNNEL_CERT_FILE
  read -r -d '' user_opts << EOM || true
setuid = $CONTRAIL_UID
setgid = $CONTRAIL_GID
EOM

# Stunnel should listen on 2 ip address - my_ip and localhost
if [[ -z "$REDIS_LISTEN_ADDRESS" && -n "$REDIS_NODES" ]]; then
  for i in {1..10} ; do
    my_ip_and_order=$(find_my_ip_and_order_for_node REDIS)
    if [ -n "$my_ip_and_order" ]; then
      break
    fi
    sleep 1
  done
  redis_node_ip=$(echo $my_ip_and_order | cut -d ' ' -f 1)
  [ -n "$redis_node_ip" ] && REDIS_LISTEN_ADDRESS=${redis_node_ip}
fi

# Populating stunnel.conf file
cat > $STUNNEL_CONF_FILE << EOM
$user_opts
cert = $STUNNEL_CERT_FILE
pid = /var/run/stunnel.pid
sslVersion = TLSv1.2
foreground = yes
[redis]
accept = $REDIS_LISTEN_ADDRESS:$REDIS_SERVER_PORT
connect = 127.0.0.1:$REDIS_SERVER_PORT

EOM

exec "$@"
