ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Vrouter Agent" \
      description="The vRouter agent is a user space process running inside Linux. It acts as the local, lightweight control plane."

RUN  yum install -y dhclient NetworkManager contrail-vrouter-agent haproxy libvirt-client \
     python-opencontrail-vrouter-netns python-contrail-vrouter-api && \
     yum clean all -y && \
     rm -rf /var/cache/yum && \
     ldconfig   

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-agent"]

ENV SERVICE_NAME=agent
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
