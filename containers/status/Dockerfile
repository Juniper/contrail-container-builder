ARG CONTRAIL_BASE_REGISTRY
ARG CONTRAIL_BASE_CONTAINER_TAG
FROM ${CONTRAIL_BASE_REGISTRY}/contrail-base:${CONTRAIL_BASE_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ENV VENDOR_DOMAIN=$VENDOR_DOMAIN
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Container with code of contrail-status tool" \
      description="Display a list of all components of a Contrail server node and report their current status of active or inactive."

RUN yum install -y python2-docker PyYAML \
                   contrail-lib \
                   contrail-setup \
                   contrail-utils \
                   python-contrail && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY contrail-status.py /root
COPY entrypoint.sh /

ENV CONTRAIL_STATUS_OPTS=""

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /root/contrail-status.py $CONTRAIL_STATUS_OPTS

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
