ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

MAINTAINER Pawel Kopka <pawel.kopka@codilime.com>

RUN yum install -y openvpn && \
    yum clean all && \
    rm -rf /var/cache/yum

VOLUME ["/etc/multicloud/openvpn/", "/etc/multicloud/ssl/"]

CMD ["/usr/sbin/openvpn"]

