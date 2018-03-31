ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-debuginfo contrail-vrouter-dpdk-debuginfo contrail-manifest
RUN ln -s /opt/contrail/manifest.xml /manifest.xml

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
