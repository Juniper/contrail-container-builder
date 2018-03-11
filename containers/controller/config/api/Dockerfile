ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y python-neutron-lib python-pip python-novaclient && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    pip install --upgrade pip && \
    pip install "inflection>=0.3.1" "jxmlease>=1.0.1" "junos-eznc>=2.1.7" && \
    ansible-galaxy install Juniper.junos

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-api","--conf_file","/etc/contrail/contrail-api.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf","--worker_id","0"]

LABEL net.juniper.nodemgr.filter.name=contrail-api
LABEL net.juniper.contrail.service=api
