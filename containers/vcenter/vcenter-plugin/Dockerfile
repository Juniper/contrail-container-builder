ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y libcontrail-java-api libcontrail-vijava \
      libcontrail-vrouter-java-api contrail-vcenter-plugin \
      python-contrail contrail-utils contrail-setup \
      openjdk-8-jre-headless && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vcenter-plugin"]

LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller

