#!/bin/bash -x


f=${1:-'contrail-template.yaml'}


labels=$(grep -A 4 nodeAffinity $f | sed 's/"//g' | grep key | awk '{print $3}')



function do_label() {
  local node=$1
  local filters=${2:-'.*'}
  for l in $labels ; do
    if echo $l | grep -q "$filters" ; then
      kubectl label nodes $node ${l}=
    fi
  done
}




do_label master

#do_label slave1 config$
#do_label slave2 config$
do_label slave1 analytics$
do_label slave2 analytics$

kubectl get nodes --show-labels

