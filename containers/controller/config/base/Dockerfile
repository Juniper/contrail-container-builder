ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG

FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ENV VENDOR_DOMAIN=$VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
ENV CONTRAIL_BUILD_FROM_SOURCE=$CONTRAIL_BUILD_FROM_SOURCE

RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]]; then \
    sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
    yum install -y contrail-config contrail-config-openstack && \
    yum clean all -y && \
    rm -rf /var/cache/yum; \
    fi

COPY *.sh /

ENV NODE_TYPE=config
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]