ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ENV VENDOR_DOMAIN=$VENDOR_DOMAIN

# contrail-config-openstack contains svc_monitor and vnc_openstack modules
<<<<<<< HEAD   (511b0c changes done to pin haproxy img version to fix CE-10114)
RUN sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
=======
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python2 - 'pip==20.1' && \
    sed -e '/^tsflags=nodocs/d' -i /etc/yum.conf && \
>>>>>>> CHANGE (20a227 fix url for get-pip.py)
    yum install -y contrail-config contrail-config-openstack && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV NODE_TYPE=config
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
