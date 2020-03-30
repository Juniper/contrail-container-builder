ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="A common tool for debugging" \
      description="The image contains scripts to debug Contrail processes."

RUN yum install -y python-paramiko python-yaml python-crypto sudo openssh-clients && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
