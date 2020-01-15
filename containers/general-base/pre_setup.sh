#!/bin/bash
YUM_ENABLE_REPOS=$(echo $YUM_ENABLE_REPOS | tr -d '"')
if [[ -n "$YUM_ENABLE_REPOS" ]] ; then
    echo "INFO: contrail-general-base: enable repos $YUM_ENABLE_REPOS"
    yum-config-manager --enable $YUM_ENABLE_REPOS
    yum clean metadata
fi
yum update -y
yum install -y yum-plugin-priorities
GENERAL_EXTRA_RPMS=$(echo $GENERAL_EXTRA_RPMS | tr -d '"' | tr ',' ' ')
if [[ -n "$GENERAL_EXTRA_RPMS" ]] ; then \
    echo "INFO: contrail-general-base: install $GENERAL_EXTRA_RPMS"
    yum install -y $GENERAL_EXTRA_RPMS
fi
groupadd --gid $CONTRAIL_GID --system $CONTRAIL_USER && \
useradd -md /home/contrail --uid $CONTRAIL_UID --shell /sbin/nologin --system --gid $CONTRAIL_GID $CONTRAIL_USER
