#!/bin/bash
version=$CONTRAIL_VERSION
registry=$CONTRAIL_REGISTRY
repository=$CONTRAIL_REPOSITORY

env_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$env_dir" ]]; then env_dir="$PWD"; fi
env_file="$env_dir/common.env"
if [ -f $env_file ]; then
  source $env_file
fi

version=${version:-${CONTRAIL_VERSION:-'4.0.1.0-32'}}
registry=${registry:-${CONTRAIL_REGISTRY:-'auto'}}
repository=${repository:-${CONTRAIL_REPOSITORY:-'auto'}}

host_ip=${HOST_IP:-'auto'}
if [ $host_ip == 'auto' ]; then
  default_interface=`ip route show | grep "default via" | awk '{print $5}'`
  host_ip=`ip address show dev $default_interface | head -3 | tail -1 | tr "/" " " | awk '{print $2}'`
fi

config_nodes=${CONFIG_NODES:-$host_ip}
controller_nodes=${CONTROLLER_NODES:-$host_ip}
analytics_nodes=${ANALYTICS_NODES:-$host_ip}
analyticsdb_nodes=${ANALYTICSDB_NODES:-$host_ip}
api_server=${API_SERVER:-$host_ip}
physical_interface=${PHYSICAL_INTERFACE:-`ip route show | grep "default via" | awk '{print $5}'`}

default_registry_ip=${_CONTRAIL_REGISTRY_IP:-$host_ip}

if [ $registry == 'auto' ]; then
  registry=$default_registry_ip':5000'
fi
if [ $repository == 'auto' ]; then
  repository='http://'$default_registry_ip'/'$version
fi
