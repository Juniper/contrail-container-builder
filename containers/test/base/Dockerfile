ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_VERSION}

RUN yum install -y \
      vim tcpdump strace ant git ipmitool patch sshpass bzip2 wget sudo python-pip \
      python-ceilometerclient python-cinderclient python-neutronclient \
      python-glanceclient python-heatclient python-novaclient && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig

RUN sudo pip install -U pip

RUN mkdir -p /images

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/bash"]

LABEL net.juniper.nodemgr.filter.name=contrail-base-test
LABEL net.juniper.contrail=base-test
LABEL net.juniper.node=test
