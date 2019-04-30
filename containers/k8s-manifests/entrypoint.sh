#!/bin/bash

set -e
cd /contrail-container-builder/kubernetes/manifests

PROPER_MANIFESTS=(*.yaml)
for PROPER_MANIFEST in ${PROPER_MANIFESTS[@]} ; do
    if [[ $KUBE_MANIFEST == $PROPER_MANIFEST ]] ; then
        ./resolve-manifest.sh $KUBE_MANIFEST
        exit 0    
    fi
done

echo "No KUBE_MANIFEST was specified. Possible values: ${PROPER_MANIFESTS[@]}"