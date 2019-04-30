#!/bin/bash

set -e
cd /contrail-container-builder/kubernetes/manifests

if [[ -z "$KUBE_MANIFEST" ]]; then
    printf "Acceptable values for KUBE_MANIFEST:\n$(ls *.yaml)\n"
else
    ./resolve-manifest.sh $KUBE_MANIFEST
fi