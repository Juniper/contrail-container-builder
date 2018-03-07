#!/bin/bash

source /common.sh

wait_for_contrail_api

function provision() {
  local script=$1
  shift 1
  local rest_params="$@"
  local retries=${PROVISION_RETRIES:-10}
  local pause=${PROVISION_DELAY:-3}
  for (( i=0 ; i < retries ; ++i )) ; do
    echo "Provisioning: $script $rest_params: $i/$retries"
    if python /opt/contrail/utils/$script $rest_params --api_server_ip $CONFIG_API_VIP --api_server_port $CONFIG_API_PORT $AUTH_PARAMS ; then
      echo "Provisioning: $script $rest_params: succeeded"
      break
    fi
    sleep $pause
  done
}

function provision_node() {
  local script=$1
  local host_ip=$2
  local host_name=$3
  shift 3
  local rest_params="$@"
  provision $script --oper add --host_name $host_name --host_ip $host_ip $rest_params
}


case $NODE_TYPE in

config)
  host_ip=$(get_listen_ip_for_node CONFIG)
  provision_node provision_config_node.py $host_ip $DEFAULT_HOSTNAME
  provision provision_linklocal.py --oper add \
    --linklocal_service_name $LINKLOCAL_SERVICE_NAME \
    --linklocal_service_ip $LINKLOCAL_SERVICE_IP \
    --linklocal_service_port $LINKLOCAL_SERVICE_PORT \
    --ipfabric_service_ip $IPFABRIC_SERVICE_IP \
    --ipfabric_service_port $IPFABRIC_SERVICE_PORT
  provision provision_alarm.py
  provision provision_encap.py --encap_priority $ENCAP_PRIORITY
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
  host_ip=$(get_listen_ip_for_node CONTROL)
  if [[ "$BGP_AUTO_MESH" == 'true' ]] ; then
    ibgp_auto_mesh_opt='--ibgp_auto_mesh'
  else
    ibgp_auto_mesh_opt='--no_ibgp_auto_mesh'
  fi
  subcluster_option=''
  if [[ -n ${SUBCLUSTER} ]]; then
    subcluster_option="--sub_cluster_name ${SUBCLUSTER}"
  fi
  provision_node provision_control.py $host_ip $DEFAULT_HOSTNAME \
    --router_asn ${BGP_ASN} $ibgp_auto_mesh_opt \
    --bgp_server_port ${BGP_PORT} ${subcluster_option}
  ;;

vrouter)
  host_ip=$(get_default_ip)
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
  provision_node provision_vrouter.py $host_ip ${VROUTER_HOSTNAME:-${DEFAULT_HOSTNAME}} $params

esac
