ARG UBUNTU_DISTR=ubuntu
ARG UBUNTU_DISTR_VERSION=18.04
FROM $UBUNTU_DISTR:$UBUNTU_DISTR_VERSION
ARG VENDOR_NAME
ARG VENDOR_DOMAIN
ARG CONTRAIL_VERSION
ARG CONTRAIL_CONTAINER_TAG
ARG CONTAINER_NAME
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail vrouter kernel module for ubuntu" \
      description="This image is used to build vrouter.ko for current ubuntu operating system that it's running on."

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

# This image is used to build vrouter.ko for current ubuntu OS that it's running on.
# This container uses rpm packages to obtain source of vrouter kernel driver.
# The container needs /usr/src and /lib/modules mounted from the host to build driver.
# And we need to move out /usr/src all that packages can install there.

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

#TODO: need to get rid of apt-get update
RUN mkdir -p /opt/contrail/src /contrail_tools /vrouter_src && \
    contrail_version=${CONTRAIL_VERSION:-$CONTRAIL_CONTAINER_TAG} && \
    echo "${contrail_version}" > /contrail_version && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends dkms && \
    apt-get install -y --no-install-recommends yum yum-utils rpm2cpio cpio && \
    yum install -y contrail-vrouter-source && \
    mv /usr/src/* /opt/contrail/src/ && \
    vrouter_path=$(find /opt/contrail/src -type f -name "contrail-vrouter-*.tar.gz") && \
    cd  /vrouter_src && \
    tar -xf "${vrouter_path}" && \
    cd /contrail_tools && \
    yumdownloader contrail-vrouter-utils && \
    rpm2cpio $(ls contrail-vrouter-utils*.rpm) | cpio -iuvd && \
    rm -f $(ls contrail-vrouter-utils*.rpm) && \
    cd .. && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    apt-get purge -y yum yum-utils rpm2cpio cpio && \
    apt-get autoremove -y

COPY dkms.conf /opt/contrail/src/
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
