ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

COPY entrypoint.sh /
COPY setup /setup/

WORKDIR /setup/
RUN yum install -y python-setuptools
RUN python setup.py install
RUN python setup.py install_lib

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-stats-client", "--config", "/etc/contrail/contrail-stats-client.conf"]

ENV CONTAINER_NAME=contrail-stats-client
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME

ENV PS1="($CONTAINER_NAME) $ "