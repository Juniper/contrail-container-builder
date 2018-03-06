ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y initscripts ethtool pciutils sudo contrail-vrouter-utils && \
    ldconfig

COPY 10-core-pattern.conf /etc/sysctl.d/
COPY *.sh /

LABEL net.juniper.contrail.pod=vrouter
CMD ["/usr/bin/tail","-f","/dev/null"]
