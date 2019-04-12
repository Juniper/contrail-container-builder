ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="vSphereESX Agent Manager" \
      description="VMware provides a standard vCenter solution called vSphereESX Agent Manager (EAM), that allows you to deploy, monitor, and manage ContrailVMs on ESXi hosts."

RUN yum install -y contrail-vcenter-manager && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python -m cvm

ENV NODE_TYPE=vcenter-manager
ENV SERVICE_NAME=manager
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME

