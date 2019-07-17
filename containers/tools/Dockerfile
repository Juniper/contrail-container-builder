ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Vrouter Agent Debug Tool" \
      description="Collect logs and other debugging related informations from vrouter and control node"

RUN yum install -y python-paramiko python-yaml python-crypto sudo openssh-clients && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY vrouter_agent_debug_info.py /root/
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /root/vrouter_agent_debug_info.py -i /root/input.yaml

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
