ARG CONTRAIL_VERSION=4.0.1.0-32
ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_VERSION}

RUN yum install -y nodejs-0.10.35-1contrail.el7 contrail-openstack-webui contrail-config-openstack \
  && yum clean all

COPY entrypoint.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
