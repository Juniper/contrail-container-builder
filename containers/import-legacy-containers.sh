#!/bin/bash

containers=(
'docker.io/opencontrail/contrail-kubernetes-agent-ubuntu16.04:4.0.1.0'
)

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/../parse-env.sh"

for cnt in ${containers[@]}; do
  docker pull $cnt
  cnt_name=$(echo $cnt | awk -F'/' '{print $NF}')
  docker tag $cnt $registry'/'$cnt_name
  docker push $registry'/'$cnt_name
done
