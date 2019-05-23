ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-vrouter-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Kernel init container for vrouter" \
      description="Prepares the host operating system for the contrail vrouter kernel interface."

# Add required license as text file in Liceses directory
RUN mkdir -p /opt/contrail/src
COPY __licensing.txt /opt/contrail/src/contrail_licensing.txt
# Copy sources for the kernel module to /opt/contrail/src
RUN yum install -y contrail-vrouter-source && \
    mv /usr/src/* /opt/contrail/src/ && \
    rpm -q --qf "%{VERSION}" contrail-vrouter-source > /opt/contrail/src/contrail_version.txt

RUN rpm -Uvh --nodeps $(repoquery --location contrail-vrouter) && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
