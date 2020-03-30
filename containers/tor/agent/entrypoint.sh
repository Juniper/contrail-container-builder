#!/bin/bash

source /common.sh

pre_start_init

toragent_ssl_config=''
if [ "$TOR_OVS_PROTOCOL" == "pssl" ]; then
  SSL_ENABLE=true \
  SERVER_CERTFILE="$TORAGENT_SSL_CERTFILE" SERVER_KEYFILE="$TORAGENT_SSL_KEYFILE" \
  /certs-init.sh
  read -r -d '' toragent_ssl_config << EOM || true
ssl_privkey=$TORAGENT_SSL_KEYFILE
ssl_cert=$TORAGENT_SSL_CERTFILE
ssl_cacert=$TORAGENT_SSL_CACERTFILE
EOM
fi

echo "INFO: Preparing /etc/contrail/contrail-tor-agent.conf"
mkdir -p /etc/contrail
cat > /etc/contrail/contrail-tor-agent.conf << EOM
[CONTROL-NODE]
servers=${XMPP_SERVERS:-`get_server_list CONTROL ":$XMPP_SERVER_PORT "`}

[DEFAULT]
collectors=$COLLECTOR_SERVERS
agent_name=${TOR_AGENT_NAME}
log_file=$CONTAINER_LOG_DIR/contrail-tor-agent-${TOR_AGENT_ID}.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
agent_mode=tor
http_server_port=$TOR_HTTP_SERVER_PORT

xmpp_auth_enable=${XMPP_SSL_ENABLE}
xmpp_dns_auth_enable=${XMPP_SSL_ENABLE}
$xmpp_certs_config

$sandesh_client_config

[NETWORKS]
control_network_ip=$(get_ip_for_vrouter_from_control)

[TOR]
tor_ip=${TOR_IP}
tor_id=${TOR_AGENT_ID}
tor_type=${TOR_TYPE}
tor_ovs_port=${TOR_OVS_PORT}
tor_ovs_protocol=${TOR_OVS_PROTOCOL}
tor_name=${TOR_NAME}
tsn_ip=${TOR_TSN_IP}
tor_vendor_name=${TOR_VENDOR_NAME}
tor_product_name=${TOR_PRODUCT_NAME}
tor_keepalive_interval=${TOR_AGENT_OVS_KA}
${toragent_ssl_config}
EOM

exec "$@"
