ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-analytics-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

COPY entrypoint.sh /

COPY /src/ /tmp/contrail-json2sandesh/
WORKDIR /tmp/contrail-json2sandesh/
RUN python setup.py install

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/lib/python2.7/site-packages/contrail-json2sandesh-0.1.0-py2.7.egg", "--config", "/etc/contrail/contrail-json2sandesh.conf"]

ENV SERVICE_NAME=contrail-json2sandesh
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
