#!/bin/bash -ex

sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf

if [ -z "$CONTRAIL_SOURCE" ] ; then
  /setup_rpm.sh
else
  /setup_src.sh
fi

yum clean all -y
rm -rf /var/cache/yum
