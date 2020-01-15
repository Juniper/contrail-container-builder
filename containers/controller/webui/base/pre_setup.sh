#!/bin/bash
BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ')
if [[ -n "$BASE_EXTRA_RPMS" ]] ; then
    echo "INFO: contrail-web-base: install $BASE_EXTRA_RPMS"
    yum install -y $BASE_EXTRA_RPMS
fi
