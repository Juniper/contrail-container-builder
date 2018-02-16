FROM ubuntu:16.04

# This image is used to build vrouter.ko for current ubuntu OS that it's running on.
# This container uses rpm packages to obtain source of vrouter kernel driver.
# The container needs /usr/src and /lib/modules mounted from the host to build driver.
# And we need to move out /usr/src all that packages can install there.

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y yum dkms && \
    yum install -y contrail-vrouter-source && \
    mkdir -p /opt/contrail/src && mv /usr/src/* /opt/contrail/src/ && \
    apt-get purge -y yum && \
    apt-get autoremove -y

COPY dkms.conf /opt/contrail/src/
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail=vrouter-build-driver-init
LABEL net.juniper.node=agent
