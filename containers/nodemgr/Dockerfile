ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-nodemgr docker-python && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /usr/bin/contrail-nodemgr --nodetype=${NODEMGR_TYPE}

LABEL net.juniper.contrail.service=nodemgr
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
