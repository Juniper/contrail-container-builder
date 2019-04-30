#!/bin/bash
cd /contrail-container-builder/kubernetes/manifests
./resolve-manifest.sh $KUBE_MANIFEST
cd ~
exec "$@"