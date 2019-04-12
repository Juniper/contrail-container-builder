ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-vcenter-manager" \
      summary="vSphereESX Agent Manager" \
      description="VMware provides a standard vCenter solution called vSphereESX Agent Manager (EAM), \n\
                  that allows you to deploy, monitor, and manage ContrailVMs on ESXi hosts."

ARG CONTAINER_NAME

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

