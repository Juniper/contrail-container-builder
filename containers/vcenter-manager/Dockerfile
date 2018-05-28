ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN yum install -y contrail-vcenter-manager && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python -m cvm

LABEL net.juniper.contrail.service=vcenter-manager
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME

