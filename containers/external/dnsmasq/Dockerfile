ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

LABEL summary="DNSMASQ" \
	  description="DNSMASQ interacts with DHCP agent in OpenStack Neutron." \
	
ARG CONTAINER_NAME

COPY *.sh /

RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    yum install -y dnsmasq && \
    echo "conf-dir=/etc/dnsmasq,*.conf" > /etc/dnsmasq.conf && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dnsmasq", "-k", "-p0"]

ENV SERVICE_NAME=dnsmasq
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
