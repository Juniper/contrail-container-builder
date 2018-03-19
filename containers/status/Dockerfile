ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y docker-python && \
    yum clean all -y && \
    rm -rf /var/cache/yum

RUN echo "CONTRAIL_REGISTRY='$CONTRAIL_REGISTRY'" > /version && \
    echo "CONTRAIL_VERSION='$CONTRAIL_VERSION'" >> /version
COPY contrail-status.py /root
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /root/contrail-status.py

LABEL net.juniper.contrail=contrail-status
