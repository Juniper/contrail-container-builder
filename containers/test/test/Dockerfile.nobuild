ARG CONTRAIL_TEST_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=ocata
FROM ${CONTRAIL_TEST_REGISTRY}/contrail-test-${OPENSTACK_VERSION}:latest

COPY *.repo /etc/yum.repos.d/

RUN yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig

RUN yum install -y python-contrail contrail-test contrail-fabric-utils

RUN mkdir -p /contrail-test/images

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.nodemgr.filter.name=contrail-test
LABEL net.juniper.contrail=test
LABEL net.juniper.node=test
