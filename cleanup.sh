#!/bin/bash -x

kubectl delete -f ./kubernetes/manifests/contrail-micro.yaml

for i in {1..100} ; do
  echo "waiting till pods destroyed $i"
  if ! kubectl get pods --all-namespaces | grep -q 'contrail\|zabbix\|cassandra' ; then
    break
  fi
  sleep 1
done


for id in $(docker ps --all | awk '/contrail/ {print ($1)}') ; do
  docker kill $id
done


for id in $(docker images | awk '/contrail/ {print ($3)}') ; do
  docker rmi $id
done

