ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-openstack-analytics python-sqlalchemy && \
    yum clean all -y && \
    rm -rf /var/cache/yum

CMD ["/usr/bin/tail","-f","/dev/null"]
