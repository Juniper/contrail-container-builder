#!/bin/bash
# Internal script for parsing common.env. Run by other executable scripts

env_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$env_dir" ]]; then env_dir="$PWD"; fi
env_file="$env_dir/common.env"
if [ -f $env_file ]; then
  source $env_file
  export ENV_FILE="$env_file"
fi

default_interface=`ip route show | grep "default via" | awk '{print $5}'`
default_gateway=`ip route show dev $default_interface | grep default | awk '{print $3}'`

linux_id=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')
if [[ "$linux_id" == 'centos' ]] ; then
  # ver id is taken from available versions from docker.io
  linux_ver_id=`cat /etc/redhat-release | awk '{print($4)}'`
else
  # for ubuntu ver id matchs 14.04, 16.04, etc from host system
  linux_ver_id=$(awk -F"=" '/^VERSION_ID=/{print $2}' /etc/os-release | tr -d '"')
fi
# build platform info
export LINUX_ID=$linux_id
export LINUX_VER_ID=$linux_ver_id

export HOST_IP=${HOST_IP:-'auto'}
if [[ $HOST_IP == 'auto' ]] ; then
  export HOST_IP=`ip address show dev $default_interface | head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
fi

export CONTRAIL_VERSION=${CONTRAIL_VERSION:-'4.1.0.0-8'}
export OPENSTACK_VERSION=${OPENSTACK_VERSION:-'ocata'}
declare -A _os_subversions
_os_subversions=([newton]=5 [ocata]=3 [pike]=1)
_os_subversion="${_os_subversions[$OPENSTACK_VERSION]}"
export OS_SUBVERSION=${OS_SUBVERSION:-"$_os_subversion"}
export CONTRAIL_CONTAINER_TAG="${CONTRAIL_VERSION}-${OPENSTACK_VERSION}"

default_packages_url="https://s3-us-west-2.amazonaws.com/contrailrhel7/contrail-install-packages-${CONTRAIL_VERSION}~${OPENSTACK_VERSION}.el7.noarch.rpm"

export BUILD_TEST_CONTAINER=${BUILD_TEST_CONTAINER:-0}
export CONTRAIL_INSTALL_PACKAGES_URL=${CONTRAIL_INSTALL_PACKAGES_URL:-$default_packages_url}
export CONTRAIL_REGISTRY=${CONTRAIL_REGISTRY:-'auto'}
export CONTRAIL_TEST_REGISTRY=${CONTRAIL_TEST_REGISTRY:-$CONTRAIL_REGISTRY}
export CONTRAIL_REPOSITORY=${CONTRAIL_REPOSITORY:-'auto'}
default_registry_ip=${_CONTRAIL_REGISTRY_IP:-${HOST_IP}}
if [[ $CONTRAIL_REGISTRY == 'auto' ]] ; then
  export CONTRAIL_REGISTRY="${default_registry_ip}:5000"
fi
if [[ $CONTRAIL_REPOSITORY == 'auto' ]] ; then
  export CONTRAIL_REPOSITORY="http://${default_registry_ip}/${CONTRAIL_VERSION}-${OPENSTACK_VERSION}"
fi

export CONTROLLER_NODES=${CONTROLLER_NODES:-$HOST_IP}
export AGENT_NODES=${AGENT_NODES:-$CONTROLLER_NODES}
export ANALYTICS_NODES=${ANALYTICS_NODES:-$CONTROLLER_NODES}
export ANALYTICSDB_NODES=${ANALYTICSDB_NODES:-$CONTROLLER_NODES}
export CONFIG_NODES=${CONFIG_NODES:-$CONTROLLER_NODES}
export CONFIGDB_NODES=${CONFIGDB_NODES:-$CONFIG_NODES}
export CONTROL_NODES=${CONTROL_NODES:-$CONFIG_NODES}
export KAFKA_NODES=${KAFKA_NODES:-$ANALYTICSDB_NODES}
export LOG_LEVEL=${LOG_LEVEL:-'SYS_NOTICE'}
export METADATA_PROXY_SECRET=${METADATA_PROXY_SECRET:-'contrail'}
export PHYSICAL_INTERFACE=${PHYSICAL_INTERFACE:-$default_interface}
export VROUTER_GATEWAY=${VROUTER_GATEWAY:-$default_gateway}
export RABBITMQ_NODES=${RABBITMQ_NODES:-$CONFIG_NODES}
export RABBITMQ_NODE_PORT=${RABBITMQ_NODE_PORT:-'5672'}
export REDIS_NODES=${REDIS_NODES:-$ANALYTICS_NODES}
export WEBUI_NODES=${WEBUI_NODES:-$CONFIG_NODES}
export ZOOKEEPER_ANALYTICS_PORT=${ZOOKEEPER_ANALYTICS_PORT:-'2182'}
export ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-$CONFIG_NODES}
export ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-'2181'}
export ZOOKEEPER_PORTS=${ZOOKEEPER_PORTS:-'2888:3888'}

export ANALYTICS_API_VIP=${ANALYTICS_API_VIP}
export CONFIG_API_VIP=${CONFIG_API_VIP}
export WEBUI_VIP=${WEBUI_VIP}

export AAA_MODE=${AAA_MODE:-'no-auth'}
export AUTH_MODE=${AUTH_MODE:-'noauth'}
export CLOUD_ORCHESTRATOR=${CLOUD_ORCHESTRATOR:-'none'}

export KUBERNETES_API_SERVER=${KUBERNETES_API_SERVER:-$HOST_IP}
