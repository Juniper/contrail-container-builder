#!/bin/bash -x


f=${1:-'contrail-template.yaml'}


labels=$(grep -A 4 nodeAffinity $f | sed 's/"//g' | grep key | awk '{print $3}')


for n in master slave1 slave2 ; do

  for l in $labels ; do

    kubectl label nodes $n ${l}-

  done

done


kubectl get nodes --show-labels

