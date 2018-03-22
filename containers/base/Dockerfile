# This is the base for contrail specific children

ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG OPENSTACK_VERSION=newton
ARG OPENSTACK_SUBVERSION=5

# note: ldconfig looks strange. contrail-lib installs shared libraries but do not call it...
RUN mkdir -p -m 777 /var/crashes && \
    yum update -y && \
    yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-$OPENSTACK_VERSION/rdo-release-$OPENSTACK_VERSION-$OPENSTACK_SUBVERSION.noarch.rpm && \
    yum install -y contrail-lib contrail-setup contrail-utils python-contrail && \
    ldconfig

COPY 10-core-pattern.conf /etc/sysctl.d/
COPY *.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
