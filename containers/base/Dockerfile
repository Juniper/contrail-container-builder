# This is the base for contrail specific children

ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG OPENSTACK_VERSION=newton
ARG OPENSTACK_SUBVERSION=5
ARG BASE_EXTRA_RPMS="https://repos.fedorapeople.org/repos/openstack/openstack-$OPENSTACK_VERSION/rdo-release-$OPENSTACK_VERSION-$OPENSTACK_SUBVERSION.noarch.rpm"

# note: ldconfig looks strange. contrail-lib installs shared libraries but do not call it...
RUN mkdir -p -m 777 /var/crashes && \
    BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ') && \
    if [[ -n "$BASE_EXTRA_RPMS" ]] ; then \
        echo "INFO: contrail-base: install $BASE_EXTRA_RPMS" ; \
        yum install -y $BASE_EXTRA_RPMS ; \
    fi && \
    yum install -y contrail-lib contrail-setup contrail-utils python-contrail && \
    ldconfig

COPY *.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
