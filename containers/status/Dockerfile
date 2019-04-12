ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

LABEL name="contrail-status" \
      summary="contrail status" \
      description="Display a list of all components of a Contrail server node \n\
                  (such as control, configuration, database, Web-UI, analytics, or vrouter) \n\
                  and report their current status of active or inactive."

ARG CONTAINER_NAME

RUN yum install -y python2-docker PyYAML && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY contrail-status.py /root
COPY entrypoint.sh /

ENV CONTRAIL_STATUS_OPTS=""

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /root/contrail-status.py $CONTRAIL_STATUS_OPTS

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
