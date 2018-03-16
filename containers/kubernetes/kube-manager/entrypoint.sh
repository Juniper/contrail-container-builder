#!/bin/bash

source /common.sh

if [ $K8S_TOKEN_FILE ]; then
  K8S_TOKEN=$(cat $K8S_TOKEN_FILE)
fi

cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

cat > /etc/contrail/contrail-kubernetes.conf << EOM
[DEFAULTS]
orchestrator=${CLOUD_ORCHESTRATOR}
token=$K8S_TOKEN
log_file=$LOG_DIR/contrail-kube-manager.log
log_level=$LOG_LEVEL
log_local=$LOG_LOCAL
nested_mode=${KUBEMANAGER_NESTED_MODE:-"0"}

[KUBERNETES]
kubernetes_api_server=${KUBERNETES_API_SERVER:-${DEFAULT_LOCAL_IP}}
kubernetes_api_port=${KUBERNETES_API_PORT:-8080}
kubernetes_api_secure_port=${KUBERNETES_API_SECURE_PORT:-6443}
cluster_name=${KUBERNETES_CLUSTER_NAME:-"k8s"}
cluster_project=${KUBERNETES_CLUSTER_PROJECT:-"{}"}
cluster_network=${KUBERNETES_CLUSTER_NETWORK:-"{}"}
pod_subnets=${KUBERNETES_POD_SUBNETS:-"10.32.0.0/12"}
ip_fabric_subnets=${KUBERNETES_IP_FABRIC_SUBNETS:-"10.64.0.0/12"}
service_subnets=${KUBERNETES_SERVICE_SUBNETS:-"10.96.0.0/12"}
ip_fabric_forwarding=${KUBERNETES_IP_FABRIC_FORWARDING:-"false"}
ip_fabric_snat=${KUBERNETES_IP_FABRIC_SNAT:-"false"}

[VNC]
public_fip_pool=${KUBERNETES_public_fip_pool:-"{}"}
vnc_endpoint_ip=$CONFIG_API_VIP
vnc_endpoint_port=$CONFIG_API_PORT

rabbit_server=$RABBITMQ_SERVERS
$rabbitmq_auth_config

cassandra_server_list=$cassandra_server_list
collectors=$COLLECTOR_SERVERS
EOM

add_ini_params_from_env KUBERNETES /etc/contrail/contrail-kubernetes.conf

set_third_party_auth_config
set_vnc_api_lib_ini

wait_for_contrail_api

exec "$@"
