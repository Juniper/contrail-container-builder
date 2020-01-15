#!/bin/bash
BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ')
if [[ -n "$BASE_EXTRA_RPMS" ]] ; then
    echo "INFO: contrail-web-base: install $BASE_EXTRA_RPMS"
    yum install -y $BASE_EXTRA_RPMS
fi
pushd $build_root
chown -R $CONTRAIL_USER:$CONTRAIL_USER contrail-web-controller
chown -R $CONTRAIL_USER:$CONTRAIL_USER contrail-web-core
popd
mkdir -p /usr/src/contrail/contrail-web-controller /usr/src/contrail/contrail-web-core
