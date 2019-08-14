ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG PROJECT_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail vCenter Fabric Manager" \
      description="CVFM manages VMware datacenter underlay network configuration based on vCenter events"

RUN yum install -y contrail-vcenter-fabric-manager && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python -m cvfm

ENV NODE_TYPE=vcenter-fabric-manager
ENV SERVICE_NAME=fabric-manager
LABEL $PROJECT_DOMAIN".service"=$SERVICE_NAME
LABEL $PROJECT_DOMAIN".container.name"=$CONTAINER_NAME
