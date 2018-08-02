ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME

RUN yum install -y git && \
    yum install -y python-pip && \
    pip install 'ansible==2.5.2' && \
    git clone https://github.com/Juniper/openshift-ansible -b release-3.7-contrail /root/openshift-ansible3.7 && \
    git clone https://github.com/Juniper/openshift-ansible -b release-3.9-contrail /root/openshift-ansible3.9 && \
    yum clean all -y && \
    rm -rf /var/cache/yum

