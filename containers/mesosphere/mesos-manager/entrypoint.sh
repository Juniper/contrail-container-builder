#!/bin/bash

source /common.sh

pre_start_init

cassandra_server_list=$(echo $CONFIGDB_SERVERS | sed 's/,/ /g')

mkdir -p /etc/contrail
cat > /etc/contrail/contrail-mesos.conf << EOM
[MESOS]
mesos_cni_server=$DEFAULT_LOCAL_IP
mesos_cni_port=6991
pod_task_subnets=${MESOS_POD_SUBNETS:-"10.32.0.0/12"}
ip_fabric_subnets=${MESOS_IP_FABRIC_SUBNETS:-"10.64.0.0/12"}

[VNC]
vnc_endpoint_ip=$CONFIG_NODES
vnc_endpoint_port=$CONFIG_API_PORT
admin_user=admin
admin_password=admin
admin_tenant=admin
rabbit_server=$RABBITMQ_NODES
rabbit_port=$RABBITMQ_NODE_PORT
cassandra_server_list=$cassandra_server_list
cassandra_use_ssl=${CASSANDRA_SSL_ENABLE,,}
cassandra_ca_certs=$CASSANDRA_SSL_CA_CERTFILE

[DEFAULTS]
disc_server_ip=127.0.0.1
disc_server_port=5998
log_local=$LOG_LOCAL
log_level=$LOG_LEVEL
log_file=$LOG_FOLDER_ABS_PATH/contrail-mesos-manager.log

$sandesh_client_config

$collector_stats_config
EOM

add_ini_params_from_env MESOSPHERE /etc/contrail/contrail-mesos.conf

set_third_party_auth_config
set_vnc_api_lib_ini

run_service "$@"
