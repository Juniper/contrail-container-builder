ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="VMware vCenter plugin" \
      description="VMware vCenter plugin workflows are represented as simple workflows in vRO plugin."

RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
      yum install -y java-1.7.0-openjdk \
      libcontrail-java-api libcontrail-vijava \
      libcontrail-vrouter-java-api contrail-vcenter-plugin \
      yum clean all -y && \
      rm -rf /var/cache/yum && \
      ldconfig; \
    fi

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-vcenter-plugin"]

ENV NODE_TYPE=vcenter
ENV SERVICE_NAME=plugin
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
