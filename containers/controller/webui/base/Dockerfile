ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

RUN yum install -y nodejs-0.10.35-1contrail.el7 contrail-openstack-webui && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
