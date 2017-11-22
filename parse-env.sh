#!/bin/bash
version=$CONTRAIL_VERSION
os_version=$OPENSTACK_VERSION
registry=$CONTRAIL_REGISTRY
repository=$CONTRAIL_REPOSITORY

env_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$env_dir" ]]; then env_dir="$PWD"; fi
env_file="$env_dir/common.env"
if [ -f $env_file ]; then
  source $env_file
fi

version=${version:-${CONTRAIL_VERSION:-'4.0.2.0-35'}}
os_version=${os_version:-${OPENSTACK_VERSION:-'newton'}}
registry=${registry:-${CONTRAIL_REGISTRY:-'auto'}}
repository=${repository:-${CONTRAIL_REPOSITORY:-'auto'}}

host_ip=${HOST_IP:-'auto'}
if [ $host_ip == 'auto' ]; then
  default_interface=`ip route show | grep "default via" | awk '{print $5}'`
  host_ip=`ip address show dev $default_interface | head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
fi

controller_nodes=${CONTROLLER_NODES:-$host_ip}
control_nodes=${CONTROL_NODES:-$controller_nodes}
config_nodes=${CONFIG_NODES:-$controller_nodes}
zookeeper_nodes=${ZOOKEEPER_NODES:-$config_nodes}
configdb_nodes=${CONFIGDB_NODES:-$config_nodes}
rabbitmq_nodes=${RABBITMQ_NODES:-$config_nodes}
analytics_nodes=${ANALYTICS_NODES:-$controller_nodes}
redis_nodes=${REDIS_NODES:-$analytics_nodes}
analyticsdb_nodes=${ANALYTICSDB_NODES:-$controller_nodes}
kafka_nodes=${KAFKA_NODES:-$analyticsdb_nodes}
log_level=${LOG_LEVEL:-SYS_NOTICE}
physical_interface=${PHYSICAL_INTERFACE:-`ip route show | grep "default via" | awk '{print $5}'`}

default_registry_ip=${_CONTRAIL_REGISTRY_IP:-$host_ip}

if [ $registry == 'auto' ]; then
  registry=$default_registry_ip':5000'
fi
if [ $repository == 'auto' ]; then
  repository='http://'$default_registry_ip'/'$version
fi

kubernetes_api_server=${KUBERNETES_API_SERVER:-$host_ip}
