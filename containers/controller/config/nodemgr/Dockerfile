ARG CONTRAIL_VERSION=4.0.1.0-32
ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_VERSION}

RUN yum install -y contrail-nodemgr docker-python git

RUN git clone --depth 1 https://github.com/cloudscaling/contrail-controller.git
RUN /usr/bin/yes | cp -r /contrail-controller/src/nodemgr /usr/lib/python2.7/site-packages/

COPY entrypoint.sh /

ENV VAR_PREFIX="CONFIGNODEMGR" \
    NODEMGR_NAME="contrail-config-nodemgr"
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-nodemgr", "--nodetype=contrail-config"]

LABEL net.juniper.nodemgr.filter.name=contrail-config-nodemgr
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
