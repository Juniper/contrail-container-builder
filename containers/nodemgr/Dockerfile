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
RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
      sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf; \
      yum install -y contrail-nodemgr python2-docker chrony ntp && \
      yum clean all -y && \
      rm -rf /var/cache/yum;\
    fi    
COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /usr/bin/contrail-nodemgr --nodetype=${NODEMGR_TYPE}

ENV SERVICE_NAME=nodemgr
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
