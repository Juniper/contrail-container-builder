# This is the general base for all: non-contrail specfic like external and for contrail specific

ARG LINUX_DISTR=centos
ARG LINUX_DISTR_VER=7.4.1708
FROM $LINUX_DISTR:$LINUX_DISTR_VER

ARG GENERIC_EXTRA_RPMS="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

RUN yum update -y && \
    yum install -y yum-plugin-priorities iproute less && \
    if [[ -n "$GENERIC_EXTRA_RPMS" ]] ; then \
        yum install -y $(echo $GENERIC_EXTRA_RPMS | tr ',' ' ') ; \
    fi

COPY *.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
