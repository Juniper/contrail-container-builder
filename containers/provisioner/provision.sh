#!/bin/bash

source /common.sh

function provision() {
  local script=$1
  shift 1
  local rest_params="$@"
  local retries=${PROVISION_RETRIES:-10}
  local pause=${PROVISION_DELAY:-3}
  local servers=`echo ${CONFIG_NODES} | tr ',' ' '`
  echo "INFO: Provisioning cmdline: /opt/contrail/utils/$script $rest_params --api_server_ip {for each node from the list: $CONFIG_NODES} --api_server_port $CONFIG_API_PORT *AUTH_PARAMS*"
  for (( i=0 ; i < retries ; ++i )) ; do
    echo "INFO: Provisioning attempt $((i+1)) of $retries (pause $pause)"
    for server in $servers ; do
      if /opt/contrail/utils/$script $rest_params --api_server_ip $server --api_server_port $CONFIG_API_PORT $AUTH_PARAMS --api_server_use_ssl ${CONFIG_API_SSL_ENABLE} ; then
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

function provision_subcluster() {
  local script=$1
  shift 1
  local rest_params="$@"
  provision $script --oper add $rest_params
}

default_hostname=$(get_default_hostname)
case $NODE_TYPE in

config)
  host_ip=$(get_listen_ip_for_node CONFIG)
  host_name=$(resolve_hostname_by_ip $host_ip)
  provision_node provision_config_node.py $host_ip ${host_name:-$default_hostname}

  if [[ -n "$IPFABRIC_SERVICE_HOST" ]]; then
    fabric_host_arg=''
    if [[ $IPFABRIC_SERVICE_HOST =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      fabric_host_arg="--ipfabric_service_ip $IPFABRIC_SERVICE_HOST"
    else
      fabric_host_arg="--ipfabric_dns_service_name $IPFABRIC_SERVICE_HOST"
    fi
    provision provision_linklocal.py --oper add \
      --linklocal_service_name $LINKLOCAL_SERVICE_NAME \
      --linklocal_service_ip $LINKLOCAL_SERVICE_IP \
      --linklocal_service_port $LINKLOCAL_SERVICE_PORT \
      $fabric_host_arg \
      --ipfabric_service_port $IPFABRIC_SERVICE_PORT
  fi
  provision provision_alarm.py
  provision provision_encap.py --encap_priority $ENCAP_PRIORITY --vxlan_vn_id_mode $VXLAN_VN_ID_MODE
  dist_snat_list=""
  dist_snat_params=""
  if [[ -n "${DIST_SNAT_PROTO_PORT_LIST}" ]]; then
    proto_port_list=''
    IFS=',' read -ra proto_port_list <<< "${DIST_SNAT_PROTO_PORT_LIST}"
    for elem in "${proto_port_list[@]}"; do
      dist_snat_list+="$(echo "${elem}") "
    done
  fi
  if [[ -n "${dist_snat_list}" ]]; then
    dist_snat_params="--snat_list ${dist_snat_list}"
  fi

  provision provision_global_vrouter_config.py --oper add \
    --flow_export_rate $FLOW_EXPORT_RATE \
    ${dist_snat_params}
  ;;

database)
  host_ip=$(get_listen_ip_for_node ANALYTICSDB)
  host_name=$(resolve_hostname_by_ip $host_ip)
  provision_node provision_database_node.py $host_ip ${host_name:-$default_hostname}
  ;;

config-database)
  host_ip=$(get_listen_ip_for_node CONFIGDB)
  host_name=$(resolve_hostname_by_ip $host_ip)
  provision_node provision_config_database_node.py $host_ip ${host_name:-$default_hostname}
  ;;

analytics)
  host_ip=$(get_listen_ip_for_node ANALYTICS)
  host_name=$(resolve_hostname_by_ip $host_ip)
  provision_node provision_analytics_node.py $host_ip ${host_name:-$default_hostname}
  ;;

analytics-snmp)
  host_ip=$(get_listen_ip_for_node ANALYTICS_SNMP)
  host_name=$(resolve_hostname_by_ip $host_ip)
  provision_node provision_analytics_snmp_node.py $host_ip ${host_name:-$default_hostname}
  ;;

analytics-alarm)
  host_ip=$(get_listen_ip_for_node ANALYTICS_ALARM)
  host_name=$(resolve_hostname_by_ip $host_ip)
  provision_node provision_analytics_alarm_node.py $host_ip ${host_name:-$default_hostname}
  ;;

control)
  if is_enabled $BGP_AUTO_MESH ; then
    bgp_opts='--ibgp_auto_mesh'
  else
    bgp_opts='--no_ibgp_auto_mesh'
  fi

  # Enable 4 byte asn if configured
  if is_enabled $ENABLE_4BYTE_AS ; then
    bgp_opts="${bgp_opts} --enable_4byte_as"
  fi

  # This is done so in order to _set_ the global asn number to BGP_ASN.
  # It also passes enable_4byte_as flag so that 4 byte asn can be set
  # This call must be separate due to provision_control.py implementation
  provision provision_control.py --router_asn ${BGP_ASN} $bgp_opts

  subcluster_name=''
  if [[ -n ${SUBCLUSTER} ]]; then
    subcluster_name="--sub_cluster_name ${SUBCLUSTER}"
    subcluster_option="$subcluster_name --sub_cluster_asn ${BGP_ASN}"
    provision_subcluster provision_sub_cluster.py ${subcluster_option}
  fi

  host_ip=$(get_listen_ip_for_node CONTROL)
  host_name=$(resolve_hostname_by_ip $host_ip)
  provision_node provision_control.py $host_ip \
    ${CONTROL_HOSTNAME:-${host_name:-${default_hostname}}} \
    --router_asn ${BGP_ASN} \
    --bgp_server_port ${BGP_PORT} ${subcluster_name}

  external_routers_list=""
  external_router=""
  external_router_name=""
  external_router_ip=""
  provision_mx_params=""

  if [[ -n "${EXTERNAL_ROUTERS}" ]]; then
    IFS=",", read -ra external_routers_list <<< "${EXTERNAL_ROUTERS}"
    for elem in "${external_routers_list[@]}"; do
      if [[ $elem == *:* ]]; then
        IFS=":", read -ra external_router <<< "${elem}"
        external_router_name=${external_router[0]}
        external_router_ip=${external_router[1]}
        provision_mx_params="--router_name ${external_router_name} --router_ip ${external_router_ip} --router_asn ${BGP_ASN}"
        provision provision_mx.py $provision_mx_params
      fi
    done
  fi

  ;;

vrouter)
  # Ensure vhost0 is up.
  # Nodemgr in vrouter mode is run on the node with vhost0.
  # During vhost0 initialization there is possible race between
  # the host_ip deriving logic and vhost0 initialization
  if ! wait_nic_up vhost0 ; then
    echo "ERROR: vhost0 is not up .. exit to allow docker policy to restart container if needed"
    exit 1
  fi
  host_ip=$(get_ip_for_vrouter_from_control)
  vhost_if=$(get_iface_for_vrouter_from_control)
  if_cidr=$(get_cidr_for_nic $vhost_if)
  ip_fabric_subnet=`python3 -c "import ipaddress; print(str(ipaddress.ip_network(u'$if_cidr', strict=False)))"`
  params=''
  if is_dpdk ; then
    params="$params --dpdk_enabled"
  fi
  if is_tsn ; then
    params="$params --router_type tor-service-node --disable_vhost_vmi"
  fi
  if [[ -n ${SUBCLUSTER} ]]; then
    params="$params --sub_cluster_name ${SUBCLUSTER}"
  fi
  if [[ ${CLOUD_ORCHESTRATOR} == "kubernetes" ]] || [[ ${CLOUD_ORCHESTRATOR} == "mesos" ]]; then
    params="$params --enable_vhost_vmi_policy"
  fi
  params="$params --ip_fabric_subnet $ip_fabric_subnet"
  host_name=$(resolve_hostname_by_ip $host_ip)
  provision_node provision_vrouter.py $host_ip ${VROUTER_HOSTNAME:-${host_name:-${default_hostname}}} $params

  ;;

toragent)
  params=''
  params="$params --router_type tor-agent  --disable_vhost_vmi"
  provision_node provision_vrouter.py ${TOR_TSN_IP} ${TOR_AGENT_NAME} $params

  tor_switch_params=''
  host_name=$(resolve_hostname_by_ip $TOR_TSN_IP)
  tor_switch_params="$tor_switch_params --device_name ${TOR_NAME} --vendor_name ${TOR_VENDOR_NAME} --device_mgmt_ip ${TOR_IP} --device_tunnel_ip ${TOR_TUNNEL_IP}"
  tor_switch_params="$tor_switch_params --device_tor_agent ${TOR_AGENT_NAME} --device_tsn  ${TOR_TSN_NAME:-${host_name:-${DEFAULT_HOSTNAME}}} "
  if [[ -n "${TOR_PRODUCT_NAME}" ]]; then
    tor_switch_params="$tor_switch_params --product_name ${TOR_PRODUCT_NAME}"
  fi
  provision provision_physical_device.py $tor_switch_params

  ;;

esac
