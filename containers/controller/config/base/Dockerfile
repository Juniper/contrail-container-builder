ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTRAIL_DEPS=""
ARG CONTRAIL_SOURCE=""
ARG CONTRAIL_SOURCE_COPY=""

COPY *.sh $CONTRAIL_SOURCE_COPY /

RUN sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
    CONTRAIL_DEPS=$(echo $CONTRAIL_DEPS | tr -d '"') && \
    if [ -n "$CONTRAIL_DEPS" ] ; then \
        yum install -y ${CONTRAIL_DEPS//,/ } || exit 1 ; \
    fi && \
    time /setup.sh && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV NODE_TYPE=config
LABEL net.juniper.contrail.pod=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
