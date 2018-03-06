ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-svc-monitor","--conf_file","/etc/contrail/contrail-svc-monitor.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]

LABEL net.juniper.nodemgr.filter.name=contrail-svc-monitor
LABEL net.juniper.contrail.service=svc-monitor
