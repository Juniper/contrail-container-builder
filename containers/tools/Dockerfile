ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="A common tool for debugging" \
      description="The image contains scripts to debug Contrail processes."

# tshark is needed for sandump tool which is included into contrail-tools package
RUN yum install -y python-paramiko python-yaml python-crypto sudo openssh-clients contrail-tools bzip2 && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    wget -nv -c --tries=3 -O /tmp/tshark3_2.tar.bz2 https://github.com/tungstenfabric/tf-third-party-cache/raw/master/tshark/tshark3_2.tar.bz2 && \
    tar --skip-old-files -xvf /tmp/tshark3_2.tar.bz2 && \
    ln -s /lib64/libssh.so.4.4.0 /lib64/libssh.so.4 && \
    ln -s /lib64/libwsutil.so.11.0.0 /lib64/libwsutil.so.11 && \
    ln -s /lib64/libbrotlicommon.so.1.0.7 /lib64/libbrotlicommon.so.1 && \
    ln -s /lib64/libwiretap.so.10.0.2 /lib64/libwiretap.so.10 && \
    ln -s /lib64/libsnappy.so.1.1.4 /lib64/libsnappy.so.1 && \
    ln -s /lib64/libzstd.so.1.4.5 /lib64/libzstd.so.1 && \
    ln -s /lib64/libnghttp2.so.14.16.1 /lib64/libnghttp2.so.14 && \
    ln -s /lib64/libwireshark.so.13.0.2 /lib64/libwireshark.so.13 && \
    ln -s /lib64/libbrotlidec.so.1.0.7 /lib64/libbrotlidec.so.1


ENV PS1="\033[1m($CONTAINER_NAME)\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME

ENTRYPOINT ["/bin/bash"]
