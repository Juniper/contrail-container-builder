ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y initscripts ethtool pciutils sudo python-enum34 contrail-vrouter-utils && \
    ldconfig

COPY *.sh ifup-* ifdown-* network-functions-vrouter* /

ENV NODE_TYPE=vrouter
LABEL net.juniper.contrail.pod=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
