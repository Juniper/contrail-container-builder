ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ENV VENDOR_DOMAIN=$VENDOR_DOMAIN

RUN sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
    yum install -y contrail-config contrail-config-openstack && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV NODE_TYPE=config
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]