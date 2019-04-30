#!/bin/bash

/contrail-container-builder/kubernetes/manifests/resolve-manifest.sh /contrail-container-builder/kubernetes/manifests/$KUBE_MANIFEST
exec "$@"