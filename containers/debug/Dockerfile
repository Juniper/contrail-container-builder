ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-debuginfo
COPY manifest.xml /root/

LABEL net.juniper.nodemgr.filter.name=contrail-debug
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
