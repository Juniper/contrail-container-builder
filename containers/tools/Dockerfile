ARG CONTRAIL_BASE_REGISTRY
ARG CONTRAIL_BASE_CONTAINER_TAG
FROM ${CONTRAIL_BASE_REGISTRY}/contrail-base:${CONTRAIL_BASE_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="A common tool for debugging" \
      description="The image contains scripts to debug Contrail processes."

RUN yum install -y python-paramiko python-yaml python-crypto sudo openssh-clients \
                   contrail-lib \
                   contrail-setup \
                   contrail-utils \
                   python-contrail && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
