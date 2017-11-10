#!/bin/bash

if [ -n "$CONTRAIL_REGISTRY" ]; then
  port=$(echo $CONTRAIL_REGISTRY | awk -F':' '{print $2}')
else
  port=5000
fi

sudo docker run -d --restart=always --name registry \
  -v /opt:/var/lib/registry:Z \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:$port -p $port:$port \
  registry:2

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/config-docker.sh"

