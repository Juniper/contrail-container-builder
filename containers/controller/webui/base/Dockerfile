ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y nodejs-0.10.35-1contrail.el7 contrail-openstack-webui && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
