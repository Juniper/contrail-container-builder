ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-test-base:latest

ARG OPENSTACK_VERSION=ocata
ARG OPENSTACK_SUBVERSION=3

RUN yum install -y \
      https://repos.fedorapeople.org/repos/openstack/openstack-$OPENSTACK_VERSION/rdo-release-$OPENSTACK_VERSION-$OPENSTACK_SUBVERSION.noarch.rpm && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig

RUN yum install -y \
      python-ceilometerclient python-cinderclient python-barbicanclient \
      python-glanceclient python-heatclient python-novaclient \
      python-selenium python-kubernetes

LABEL net.juniper.nodemgr.filter.name=contrail-test
LABEL net.juniper.contrail=test
LABEL net.juniper.node=test
