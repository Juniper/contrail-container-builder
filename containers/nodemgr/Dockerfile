ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-nodemgr docker-python && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /usr/bin/contrail-nodemgr --nodetype=${NODEMGR_TYPE}

LABEL net.juniper.nodemgr.filter.name=nodemgr
LABEL net.juniper.contrail=nodemgr
