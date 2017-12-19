#!/bin/bash
# Internal script for parsing common.env. Run by other executable scripts

version=$CONTRAIL_VERSION
os_version=$OPENSTACK_VERSION
registry=$CONTRAIL_REGISTRY
repository=$CONTRAIL_REPOSITORY
packages_url=$CONTRAIL_INSTALL_PACKAGES_URL

env_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$env_dir" ]]; then env_dir="$PWD"; fi
env_file="$env_dir/common.env"
if [ -f $env_file ]; then
  source $env_file
fi

version=${version:-${CONTRAIL_VERSION:-'4.1.0.0-6'}}
os_version=${os_version:-${OPENSTACK_VERSION:-'newton'}}
registry=${registry:-${CONTRAIL_REGISTRY:-'auto'}}
repository=${repository:-${CONTRAIL_REPOSITORY:-'auto'}}
packages_url=${packages_url:-${CONTRAIL_INSTALL_PACKAGES_URL:-"https://s3-us-west-2.amazonaws.com/contrailrhel7/contrail-install-packages-$version~$os_version.el7.noarch.rpm"}}

# Calculate OS subversion (minor package version)
declare -A os_subversions
os_subversions=([newton]=5 [ocata]=3)
os_subversion="${os_subversions[$os_version]}"

host_ip=${HOST_IP:-'auto'}
default_interface=`ip route show | grep "default via" | awk '{print $5}'`
default_gateway=`ip route show dev $default_interface | grep default | awk '{print $3}'`
if [ $host_ip == 'auto' ]; then
  host_ip=`ip address show dev $default_interface | head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
fi

controller_nodes=${CONTROLLER_NODES:-$host_ip}

agent_nodes=${AGENT_NODES:-$controller_nodes}
analytics_nodes=${ANALYTICS_NODES:-$controller_nodes}
analyticsdb_nodes=${ANALYTICSDB_NODES:-$controller_nodes}
config_nodes=${CONFIG_NODES:-$controller_nodes}
configdb_nodes=${CONFIGDB_NODES:-$config_nodes}
control_nodes=${CONTROL_NODES:-$config_nodes}
kafka_nodes=${KAFKA_NODES:-$analyticsdb_nodes}
log_level=${LOG_LEVEL:-SYS_NOTICE}
physical_interface=${PHYSICAL_INTERFACE:-${default_interface}}
vrouter_gateway=${VROUTER_GATEWAY:-${default_gateway}}
rabbitmq_nodes=${RABBITMQ_NODES:-$config_nodes}
rabbitmq_node_port=${RABBITMQ_NODE_PORT}
redis_nodes=${REDIS_NODES:-$analytics_nodes}
webui_nodes=${WEBUI_NODES:-$config_nodes}
zookeeper_analytics_port=${ZOOKEEPER_ANALYTICS_PORT}
zookeeper_nodes=${ZOOKEEPER_NODES:-$config_nodes}
zookeeper_port=${ZOOKEEPER_PORT}
zookeeper_ports=${ZOOKEEPER_PORTS:-'2888:3888'}


analytics_api_vip=${ANALYTICS_API_VIP}
config_api_vip=${CONFIG_API_VIP}
webui_vip=${WEBUI_VIP}

aaa_mode=${AAA_MODE}
auth_mode=${AUTH_MODE}
cloud_orchestrator=${CLOUD_ORCHESTRATOR}

default_registry_ip=${_CONTRAIL_REGISTRY_IP:-$host_ip}

if [ $registry == 'auto' ]; then
  registry=$default_registry_ip':5000'
fi
if [ $repository == 'auto' ]; then
  repository='http://'$default_registry_ip'/'$version-$os_version
fi

kubernetes_api_server=${KUBERNETES_API_SERVER:-$host_ip}
