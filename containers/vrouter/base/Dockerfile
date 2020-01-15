ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

# removing network-scripts: this folder will mounted from the host (or not used in Ubuntu) so the one installed by initscripts package in container is removed.
RUN yum install -y initscripts ethtool pciutils sudo contrail-vrouter-utils && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig && \
    rm -rf /etc/sysconfig/network-scripts

COPY *.sh ifup-* ifdown-* network-functions-vrouter* dhclient-vhost0.conf /

ENV NODE_TYPE=vrouter
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
