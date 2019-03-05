ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
    yum install --cacheonly -y contrail-analytics python-sqlalchemy && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV NODE_TYPE=analytics-snmp
LABEL net.juniper.contrail.pod=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
