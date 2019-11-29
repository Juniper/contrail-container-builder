#!/bin/bash -e
# Internal script. Installs local docker registry. Takes CONTRAIL_REGISTRY from environment and extracts port from it,
# otherwise port=5000 is used

if [ -n "$CONTRAIL_REGISTRY" ]; then
  port=$(echo $CONTRAIL_REGISTRY | awk -F':' '{print $2}')
else
  port=5000
fi

registry_name="registry_${port}"
if ! sudo docker ps --all | grep -q "${registry_name}" ; then
  echo "Start new Docker Registry on port $port"
  sudo docker run -d --restart=always --name $registry_name\
    -v /opt:/var/lib/registry:z \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:$port -p $port:$port \
    registry:2
else
  if ! sudo docker ps | grep -q "${registry_name}" ; then
    id=`sudo docker ps --all | grep "${registry_name}" | awk '{print($1)}'`
    echo "Docker Registry on port $port is already created but stopped, start it"
    sudo docker start $id
  else
    echo "Docker Registry is already started with port $port"
  fi
fi

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/config-docker.sh"

