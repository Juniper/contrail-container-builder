ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="vSphereESX Agent Manager" \
      description="VMware provides a standard vCenter solution called vSphereESX Agent Manager (EAM), that allows you to deploy, monitor, and manage ContrailVMs on ESXi hosts."

RUN  yum install -y contrail-vcenter-manager && \
     yum clean all -y && \
     rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vcenter-manager"]

ENV NODE_TYPE=vcenter-manager
ENV SERVICE_NAME=manager
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME

