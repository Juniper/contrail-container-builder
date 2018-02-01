ARG CONTRAIL_TEST_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=ocata
FROM ${CONTRAIL_TEST_REGISTRY}/contrail-test-${OPENSTACK_VERSION}:latest

RUN yum install -y python-contrail contrail-test contrail-fabric-utils && \
    yum --setopt=obsoletes=0 install -y python-neutronclient && \
    yum clean all -y && rm -rf /var/cache/yum

RUN mkdir -p /contrail-test/images

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail=test
LABEL net.juniper.node=test
