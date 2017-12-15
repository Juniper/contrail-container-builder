ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

RUN yum install -y python-neutron-lib && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-api","--conf_file","/etc/contrail/contrail-api.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf","--worker_id","0"]

LABEL net.juniper.nodemgr.filter.name=contrail-api
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
