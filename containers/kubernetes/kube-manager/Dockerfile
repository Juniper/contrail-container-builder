ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

RUN yum install -y python-eventlet python-bitstring contrail-kube-manager python-enum34 && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-kube-manager", "-c", "/etc/contrail/contrail-kubernetes.conf"]
