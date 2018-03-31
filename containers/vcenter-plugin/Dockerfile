ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y java-1.7.0-openjdk \
    libcontrail-java-api libcontrail-vijava \
    libcontrail-vrouter-java-api contrail-vcenter-plugin \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/contrail-vcenter-plugin"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
