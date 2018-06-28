ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN yum install -y contrail-debuginfo contrail-vrouter-dpdk-debuginfo contrail-manifest
RUN ln -s /opt/contrail/manifest.xml /manifest.xml

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
