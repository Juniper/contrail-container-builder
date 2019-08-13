#!/bin/bash -ex

sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf
CONTRAIL_DEPS=$(echo ${CONTRAIL_DEPS//,/ } | tr -d '"')
CONTRAIL_RPMS=$(echo ${CONTRAIL_RPMS//,/ } | tr -d '"')
if [[ -n "$CONTRAIL_DEPS" || -n "$CONTRAIL_RPMS" ]] ; then
  time yum install -y $(echo $CONTRAIL_DEPS $CONTRAIL_RPMS | sort | uniq)
fi

if [ -n "$CONTRAIL_SOURCE" ] ; then
  time /setup_src.sh
fi

yum clean all -y
rm -rf /var/cache/yum
