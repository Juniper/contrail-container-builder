#!/bin/bash

source /common.sh

if [ $K8S_TOKEN_FILE ]; then
  K8S_TOKEN=$(cat $K8S_TOKEN_FILE)
fi

cat > /etc/contrail/contrail-kubernetes.conf << EOM
[DEFAULTS]
orchestrator=${CLOUD_ORCHESTRATOR:-kubernetes}
token=$K8S_TOKEN
log_local=${KUBEMANAGER_LOG_LOCAL:-$LOG_LOCAL}
log_level=${KUBEMANAGER_LOG_LEVEL:-$LOG_LEVEL}
log_file=${KUBEMANAGER_LOG_FILE:-"$LOG_DIR/contrail-kube-manager.log"}

[KUBERNETES]
kubernetes_api_server=${KUBERNETES_API_SERVER:-`get_listen_ip`}
kubernetes_api_port=${KUBERNETES_API_PORT:-8080}
kubernetes_api_secure_port=${KUBERNETES_API_SECURE_PORT:-6443}
service_subnets=${KUBERNETES_SERVICE_SUBNETS:-"10.96.0.0/12"}
pod_subnets=${KUBERNETES_POD_SUBNETS:-"10.32.0.0/12"}
cluster_project=${KUBERNETES_CLUSTER_PROJECT:-"{'domain': 'default-domain', 'project': 'default'}"}
cluster_name=${KUBERNETES_CLUSTER_NAME:-"k8s-default"}
;cluster_network=${KUBERNETES_CLUSTER_NETWORK:-"{}"}

[VNC]
public_fip_pool=${KUBERNETES_public_fip_pool:-"{}"}
vnc_endpoint_ip=${KUBEMANAGER_CONFIG_SERVER_LIST:- `get_server_list CONFIG ","`}
vnc_endpoint_port=$CONFIG_API_PORT
rabbit_server=$RABBITMQ_SERVERS
rabbit_vhost=$RABBITMQ_VHOST
rabbit_user=$RABBITMQ_USER
rabbit_password=$RABBITMQ_PASSWORD
cassandra_server_list=$CONFIGDB_SERVERS
collectors=$COLLECTOR_SERVERS
EOM

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"
