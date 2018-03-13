ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-nodemgr docker-python

# TODO: remove this hack - installing git, and installing nodemgr from source
RUN yum install -y git && \
    git clone --depth 1 https://github.com/juniper/contrail-controller.git && \
    cd contrail-controller && \
    git fetch https://review.opencontrail.org/Juniper/contrail-controller refs/changes/15/40515/16 && git checkout FETCH_HEAD && \
    cd .. && \
    /usr/bin/yes | cp -r /contrail-controller/src/nodemgr /usr/lib/python2.7/site-packages/

RUN yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /usr/bin/contrail-nodemgr --nodetype=${NODEMGR_TYPE}

LABEL net.juniper.nodemgr.filter.name=nodemgr
LABEL net.juniper.contrail=nodemgr
