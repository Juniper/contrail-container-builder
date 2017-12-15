ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-test-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

RUN yum install -y \
      python-ceilometerclient python-cinderclient python-neutronclient \
      python-glanceclient python-heatclient python-novaclient && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig

ENTRYPOINT ["/usr/bin/bash"]

LABEL net.juniper.nodemgr.filter.name=contrail-test
LABEL net.juniper.contrail=test
LABEL net.juniper.node=test
