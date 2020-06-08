ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack Heat" \
      description="Sidecar container with libraries for heat services."

COPY *.sh /

RUN curl https://bootstrap.pypa.io/get-pip.py | python2 - 'pip==20.1' && \
    mkdir -p /opt/contrail/site-packages /opt/contrail_python3/site-packages && \
    pip install --target=/opt/contrail/site-packages future six && \
    yum install -y python3 python3-setuptools && \
    python3 -m pip install --no-compile --target=/opt/contrail_python3/site-packages "future==0.18.2" "six==1.13.0" && \
    rpm -Uvh --nodeps $(repoquery --location python-contrail) && \
    rpm -Uvh --nodeps $(repoquery --location contrail-heat) && \
    cp -rf /usr/lib/python2.7/site-packages/contrail_heat* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/cfgm_common* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/contrail_heat* /opt/contrail_python3/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail_python3/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/cfgm_common* /opt/contrail_python3/site-packages && \
    yum autoremove -y python-contrail contrail-heat python3 python3-setuptools && \
    yum clean all -y && \
    rm -rf /var/cache/yum

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
