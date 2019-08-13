#!/bin/bash -ex

sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf
CONTRAIL_DEPS=$(echo ${CONTRAIL_DEPS//,/ } | tr -d '"')
CONTRAIL_RPMS=$(echo ${CONTRAIL_RPMS//,/ } | tr -d '"')
if [[ -n "$CONTRAIL_DEPS" || -n "$CONTRAIL_RPMS" ]] ; then
    time yum install -y $CONTRAIL_DEPS $CONTRAIL_RPMS
fi

if [ -n "$CONTRAIL_SOURCE_COPY" ] ; then
  time /setup_src.sh
fi

yum clean all -y
rm -rf /var/cache/yum
