ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ENTRYPOINT ["/entrypoint.sh"]
RUN yum install -y contrail && \
    yum clean all -y && \
    rm -rf /var/cache/yum

CMD ["contrail", "-c", "/etc/contrail/apisrv.yml"]
