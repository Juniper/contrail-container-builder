ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

COPY entrypoint.sh /

COPY setup /

# WORKDIR /setup/
# RUN python setup.py install
RUN cd /setup/ && python setup.py install

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-json2sandesh", "--config", "/etc/contrail/contrail-json2sandesh.conf"]

ENV SERVICE_NAME=contrail-json2sandesh
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
