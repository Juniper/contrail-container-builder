# This is the general base for all: non-contrail specfic like external and for contrail specific

ARG LINUX_DISTR=centos
ARG LINUX_DISTR_VER=7.4.1708
FROM $LINUX_DISTR:$LINUX_DISTR_VER

ARG GENERIC_EXTRA_RPMS=""
ARG YUM_ENABLE_REPOS=""

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

RUN YUM_ENABLE_REPOS=$(echo $YUM_ENABLE_REPOS | tr -d '"') && \
    if [[ -n "$YUM_ENABLE_REPOS" ]] ; then \
        echo "INFO: contrail-general-base: enable repos $YUM_ENABLE_REPOS" && \
        yum-config-manager --enable $YUM_ENABLE_REPOS ; \
    fi && \
    yum update -y && \
    yum install -y yum-plugin-priorities iproute less && \
    GENERIC_EXTRA_RPMS=$(echo $GENERIC_EXTRA_RPMS | tr -d '"' | tr ',' ' ') && \
    if [[ -n "$GENERIC_EXTRA_RPMS" ]] ; then \
        echo "INFO: contrail-general-base: install $GENERIC_EXTRA_RPMS" && \
        yum install -y $GENERIC_EXTRA_RPMS ; \
    fi

COPY *.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
