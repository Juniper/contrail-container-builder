ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG BASE_EXTRA_RPMS=""

# python3 is required for helper scripts
RUN BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ') && \
    if [[ -n "$BASE_EXTRA_RPMS" ]] ; then \
        echo "INFO: contrail-base: install $BASE_EXTRA_RPMS" ; \
        yum install -y $BASE_EXTRA_RPMS ; \
    fi && \
    yum install -y iproute less hostname python3 nodejs-0.10.48-1contrail.el7 contrail-web-controller contrail-web-core && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    find / -name '__pycache__' -delete -o -name "*.pyc" -delete -o -name "*.pyo" -delete && \
    chown -R $CONTRAIL_USER:$CONTRAIL_USER /usr/src/contrail

COPY custom-images/logo.png /opt/contrail/images/logo.png
COPY custom-images/favicon.ico /opt/contrail/images/favicon.ico
COPY *.sh /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENV NODE_TYPE=webui
LABEL $VENDOR_DOMAIN".pod"=$NODE_TYPE
CMD ["/usr/bin/tail","-f","/dev/null"]
