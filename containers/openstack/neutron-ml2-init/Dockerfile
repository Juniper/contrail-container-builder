ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ARG LINUX_DISTR

LABEL name=$CONTAINER_NAME \
      summary="Init container for OpenStack neutron-server with ml2 driver" \
      description="Sidecar container with libraries for neutron-server with ml2 driver."

COPY *.sh /

# run _prepare_packages.sh as a last step cause it can break some repositories
RUN curl https://bootstrap.pypa.io/get-pip.py | python2 - 'pip==20.1' && \
    mkdir -p /opt/contrail/site-packages && \
    pip install --no-compile --target=/opt/contrail/site-packages future && \
    rpm -Uvh --nodeps $(repoquery --location python-contrail) && \
    yum install -y git && \
    git clone --depth=1 --single-branch -b stable/queens https://opendev.org/x/networking-opencontrail.git && \
    cd networking-opencontrail && \
    python setup.py install --root=/opt/contrail/ --no-compile && \
    cp -rf /usr/lib/python2.7/site-packages/vnc_api* /opt/contrail/site-packages && \
    cp -rf /usr/lib/python2.7/site-packages/cfgm_common* /opt/contrail/site-packages && \
    yum autoremove -y git python-contrail tf-neutron-ml2-plugin && \
    yum clean all -y && \
    rm -rf networking-opencontrail /var/cache/yum

ENTRYPOINT ["/entrypoint.sh"]

LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
