ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail general base image" \
      description="The image contains debug symbols for build and may be used to debug Contrail processes."

RUN yum install -y contrail-debuginfo contrail-vrouter-dpdk-debuginfo contrail-manifest && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ln -s /opt/contrail/manifest.xml /manifest.xml

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
