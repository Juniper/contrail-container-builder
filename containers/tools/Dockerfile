ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="A common tool for debugging" \
      description="The image contains scripts to debug Contrail processes."

RUN yum install -y python-paramiko python-yaml python-crypto sudo openssh-clients && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY vrouter_agent_debug_info.py /usr/bin/vrouter-agent-debug-info
CMD ["/bin/bash/"]

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
