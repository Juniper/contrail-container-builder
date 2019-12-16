ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Stunnel" \
      description="Contrail Stunnel provides encryption to Redis"

COPY *.sh /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    yum install -y iproute less hostname python3 openssl stunnel && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    find / -name '__pycache__' -delete -o -name "*.pyc" -delete -o -name "*.pyo" -delete

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["stunnel", "/etc/stunnel/stunnel.conf"]

ENV SERVICE_NAME=stunnel
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
