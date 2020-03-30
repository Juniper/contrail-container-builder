ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ENV VENDOR_DOMAIN=$VENDOR_DOMAIN
ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Container with code of contrail-status tool" \
      description="Display a list of all components of a Contrail server node and report their current status of active or inactive."

RUN yum install -y python2-docker PyYAML && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY contrail-status.py /root
COPY entrypoint.sh /

ENV CONTRAIL_STATUS_OPTS=""

ENTRYPOINT ["/entrypoint.sh"]
CMD /root/contrail-status.py $CONTRAIL_STATUS_OPTS

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
