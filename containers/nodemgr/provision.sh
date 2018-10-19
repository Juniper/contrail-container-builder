#!/bin/bash

source /common.sh

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

function provision_subcluster() {
  local script=$1
  shift 1
  local rest_params="$@"
  provision $script --oper add $rest_params
}


case $NODE_TYPE in

config)
  host_ip=$(get_listen_ip_for_node CONFIG)
  provision_node provision_config_node.py $host_ip $DEFAULT_HOSTNAME

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
  provision provision_encap.py --encap_priority $ENCAP_PRIORITY
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
  provision_node provision_database_node.py $host_ip $DEFAULT_HOSTNAME
  ;;

analytics)
  host_ip=$(get_listen_ip_for_node ANALYTICS)
  provision_node provision_analytics_node.py $host_ip $DEFAULT_HOSTNAME
  ;;

control)
  if [[ "$BGP_AUTO_MESH" == 'true' ]] ; then
    ibgp_auto_mesh_opt='--ibgp_auto_mesh'
  else
    ibgp_auto_mesh_opt='--no_ibgp_auto_mesh'
  fi

  # This is done so in order to _set_ the global asn number to BGP_ASN.
  # This call must be separate due to provision_control.py implementation
  provision provision_control.py --router_asn ${BGP_ASN} $ibgp_auto_mesh_opt

  subcluster_name=''
  if [[ -n ${SUBCLUSTER} ]]; then
    subcluster_name="--sub_cluster_name ${SUBCLUSTER}"
    subcluster_option="$subcluster_name --sub_cluster_asn ${BGP_ASN}"
    provision_subcluster provision_sub_cluster.py ${subcluster_option}
  fi

  host_ip=$(get_listen_ip_for_node CONTROL)
  provision_node provision_control.py $host_ip $DEFAULT_HOSTNAME \
    --router_asn ${BGP_ASN} \
    --bgp_server_port ${BGP_PORT} ${subcluster_name}
  ;;

vrouter)
  host_ip=$(get_ip_for_vrouter_from_control)
  vhost_if=$(get_iface_for_vrouter_from_control)
  if_cidr=$(get_cidr_for_nic $vhost_if)
  ip_fabric_subnet=`python -c "import ipaddress; print str(ipaddress.ip_network(u'$if_cidr', strict=False))"`
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
  if [[ ${CLOUD_ORCHESTRATOR} == "kubernetes" ]]; then
    params="$params --enable_vhost_vmi_policy"
  fi
  params="$params --ip_fabric_subnet $ip_fabric_subnet"
  provision_node provision_vrouter.py $host_ip ${VROUTER_HOSTNAME:-${DEFAULT_HOSTNAME}} $params

esac
