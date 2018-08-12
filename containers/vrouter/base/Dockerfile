ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

# removing network-scripts:
# if host OS is CentOS then this folder is mounted from host and all works correctly.
# if host OS is Ubuntu then this folder is not mounted from host and code awaits absence of the folder. But as container was built from CentOS then folder is present there and should be removed.

RUN yum install -y initscripts ethtool pciutils sudo contrail-vrouter-utils && \
    ldconfig && \
    rm -rf /etc/sysconfig/network-scripts

COPY *.sh ifup-* ifdown-* network-functions-vrouter* /

ENV NODE_TYPE=vrouter
LABEL net.juniper.contrail.pod=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
