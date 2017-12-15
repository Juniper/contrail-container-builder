ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

RUN yum install -y contrail-nodemgr docker-python

# TODO: remove this hack - installing git, and installing nodemgr from source
RUN yum install -y git && \
    git clone --depth 1 https://github.com/cloudscaling/contrail-controller.git && \
    /usr/bin/yes | cp -r /contrail-controller/src/nodemgr /usr/lib/python2.7/site-packages/ && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /usr/bin/contrail-nodemgr --nodetype=${NODEMGR_TYPE}

LABEL net.juniper.nodemgr.filter.name=nodemgr
LABEL net.juniper.contrail=nodemgr
