ARG CONTRAIL_VERSION=4.0.1.0-32
ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_VERSION}

RUN yum install -y contrail-k8s-cni \
  && yum clean all

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
