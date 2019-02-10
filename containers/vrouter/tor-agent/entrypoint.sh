#!/bin/bash

source /common.sh
source /agent-functions.sh

function provision() {
  local script=$1
  shift 1
  local rest_params="$@"
  local retries=${PROVISION_RETRIES:-10}
  local pause=${PROVISION_DELAY:-3}
  local servers=`echo ${CONFIG_NODES} | tr ',' ' '`
  echo "INFO: Provisioning cmdline: python /opt/contrail/utils/$script $rest_params --api_server_ip {for each node from the list: $CONFIG_NODES} --api_server_port $CONFIG_API_PORT $AUTH_PARAMS"
  for (( i=0 ; i < retries ; ++i )) ; do
    echo "INFO: Provisioning attempt $((i+1)) of $retries (pause $pause)"
    for server in $servers ; do
      if python /opt/contrail/utils/$script $rest_params --api_server_ip $server --api_server_port $CONFIG_API_PORT $AUTH_PARAMS ; then
        echo "INFO: Provisioning was succeeded"
        return
      fi
    done
    sleep $pause
    ((pause+=1))
  done
  echo "ERROR: Provisioning was failed"
  exit 1
}

function provision_node() {
  local script=$1
  local host_ip=$2
  local host_name=$3
  shift 3
  local rest_params="$@"
  provision $script --oper add --host_name $host_name --host_ip $host_ip $rest_params
}

echo "INFO: Preparing /etc/contrail/contrail-tor-agent.conf"
cat > /etc/contrail/contrail-tor-agent.conf << EOM
[CONTROL-NODE]
servers=${XMPP_SERVERS:-`get_server_list CONTROL ":$XMPP_SERVER_PORT "`}

[DEFAULT]
collectors=$COLLECTOR_SERVERS
agent_name=${TOR_AGENT_NAME}
hostname=$(resolve_hostname_by_ip $vrouter_ip)
log_file=/var/log/contrail/contrail-tor-agent-${TOR_AGENT_ID}.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
agent_mode=tor
http_server_port=$TOR_HTTP_SERVER_PORT
xmpp_auth_enable=${XMPP_SSL_ENABLE}
xmpp_dns_auth_enable=${XMPP_SSL_ENABLE}

[NETWORKS]
control_network_ip=$(get_ip_for_vrouter_from_control)

[TOR]
tor_ip=${TOR_IP}
tor_id=${TOR_AGENT_ID}
tor_type=ovs
tor_ovs_port=${TOR_OVS_PORT}
tor_ovs_protocol=${TOR_OVS_PROTOCOL}
tor_name=${TOR_NAME}
tsn_ip=${TOR_TSN_IP}
tor_vendor_name=${TOR_VENDOR_NAME}
tor_product_name=${TOR_PRODUCT_NAME}
ssl_cert=${SERVER_CERTFILE}
ssl_privkey=${SERVER_KEYFILE}
ssl_cacert=${SERVER_CA_CERTFILE}
tor_keepalive_interval=${TOR_AGENT_OVS_KA}
EOM

params=''
vhost_if=$(get_iface_for_vrouter_from_control)
if_cidr=$(get_cidr_for_nic $vhost_if)
ip_fabric_subnet=`python -c "import ipaddress; print str(ipaddress.ip_network(u'$if_cidr', strict=False))"`
host_ip=$(get_ip_for_vrouter_from_control)
params="$params --router_type tor-agent  --disable_vhost_vmi"
params="$params --ip_fabric_subnet $ip_fabric_subnet"
provision_node provision_vrouter.py ${host_ip} ${TOR_AGENT_NAME} $params

tor_switch_params=''
if [[ -n "${TSN_MODE}" ]]; then
  tor_switch_params="$tor_switch_params --device_name ${TOR_NAME} --vendor_name ${TOR_VENDOR_NAME} --device_mgmt_ip ${TOR_IP} --device_tunnel_ip ${TOR_TUNNEL_IP}"
  tor_switch_params="$tor_switch_params --device_tor_agent ${TOR_AGENT_NAME} --device_tsn ${TOR_TSN_NAME} "
  if [[ -n "${TOR_PRODUCT_NAME}" ]]; then
      tor_switch_params="$tor_switch_params --product_name ${TOR_PRODUCT_NAME}"
  fi
  provision provision_physical_device.py $tor_switch_params
fi

exec "$@"
