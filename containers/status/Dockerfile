ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

RUN yum install -y contrail-nodemgr python-pip && \
    pip install docker && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY contrail-status.py /usr/bin/

CMD /usr/bin/python /usr/bin/contrail-status.py

LABEL net.juniper.contrail=contrail-status
