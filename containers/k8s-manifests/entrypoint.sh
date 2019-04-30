#!/bin/bash

set -e
cd /contrail-container-builder/kubernetes/manifests

if [[ -z "$KUBE_MANIFEST" ]]; then
    echo "Acceptable values for KUBE_MANIFEST:"
    ls *.yaml
else
    ./resolve-manifest.sh $KUBE_MANIFEST
fi