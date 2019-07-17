ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Vrouter Agent Debug Tool" \
      description="Collect logs and other debugging related informations from vrouter and control node"

RUN yum install -y python-paramiko python-yaml python-crypto sudo && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY vrouter_agent_debug_info.py /
COPY input.yaml /

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
