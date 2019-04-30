#!/bin/bash

cd /manifests_utils
cp /manifests_utils/* /manifests_temp/
./resolve-manifest.sh $KUBE_MANIFEST > /manifests_temp/contrail.yaml