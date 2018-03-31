ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN yum install -y docker-python && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY contrail-status.py /root
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /root/contrail-status.py

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
