ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ENV VENDOR_DOMAIN=$VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Node Manager" \
      description="Contrail Node Manager is a monitor process per contrail virtual node that tracks the running state of the processes."
# for building from rpms
# install chrony, ntp and iputils-clockdiff to enable checking time sync by nodemgr
RUN   yum install -y contrail-nodemgr python2-docker chrony ntp python3-contrail && \
      yum clean all -y && \
      rm -rf /var/cache/yum

COPY *.sh /
ENTRYPOINT ["/entrypoint.sh"]
# use shell form for CMD as shell variables processing is required here
CMD /usr/bin/contrail-nodemgr --nodetype=${NODEMGR_TYPE}

ENV SERVICE_NAME=nodemgr
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
