ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTRAIL_BUILD_FROM_SOURCE
RUN if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
      yum install -y contrail-analytics python-sqlalchemy && \
      yum clean all -y && \
      rm -rf /var/cache/yum; \
    fi
ENV NODE_TYPE=analytics
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
