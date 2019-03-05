ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

# install chrony, ntp and iputils-clockdiff to enable checking time sync by nodemgr
RUN yum install --cacheonly -y contrail-nodemgr python2-docker chrony ntp && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /usr/bin/contrail-nodemgr --nodetype=${NODEMGR_TYPE}

ENV SERVICE_NAME=nodemgr
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
