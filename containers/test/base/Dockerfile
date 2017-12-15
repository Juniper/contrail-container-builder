ARG CONTRAIL_VERSION=4.1.0.0-6
ARG CONTRAIL_REGISTRY=localhost:5000
ARG OPENSTACK_VERSION=newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_VERSION}-${OPENSTACK_VERSION}

RUN yum install -y python-contrail \
      vim tcpdump strace ant git ipmitool \
      patch sshpass bzip2 wget sudo python-pip && \
    yum clean all -y && \
    rm -rf /var/cache/yum

RUN mkdir -p /images

CMD ["/usr/bin/tail","-f","/dev/null"]
