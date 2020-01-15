# This is the general base for all: non-contrail specfic like external and for contrail specific

ARG LINUX_DISTR=centos
ARG LINUX_DISTR_VER=7.4.1708
FROM $LINUX_DISTR:$LINUX_DISTR_VER
ARG VENDOR_NAME

ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0"

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY licensing.txt /licenses

ARG GENERAL_EXTRA_RPMS=""
ARG YUM_ENABLE_REPOS=""

# These definitions are just for build purposes and must not be changed at runtime
ENV CONTRAIL_GID=1999
ENV CONTRAIL_UID=1999
ENV CONTRAIL_USER=contrail
# version is used by contrail-version tool
ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

RUN YUM_ENABLE_REPOS=$(echo $YUM_ENABLE_REPOS | tr -d '"') && \
    if [[ -n "$YUM_ENABLE_REPOS" ]] ; then \
        echo "INFO: contrail-general-base: enable repos $YUM_ENABLE_REPOS" && \
        yum-config-manager --enable $YUM_ENABLE_REPOS ; \
        yum clean metadata ; \
    fi && \
    yum update -y && \
    yum install -y yum-plugin-priorities && \
    GENERAL_EXTRA_RPMS=$(echo $GENERAL_EXTRA_RPMS | tr -d '"' | tr ',' ' ') && \
    if [[ -n "$GENERAL_EXTRA_RPMS" ]] ; then \
        echo "INFO: contrail-general-base: install $GENERAL_EXTRA_RPMS" && \
        yum install -y $GENERAL_EXTRA_RPMS ; \
    fi && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    groupadd --gid $CONTRAIL_GID --system $CONTRAIL_USER && \
    useradd -md /home/contrail --uid $CONTRAIL_UID --shell /sbin/nologin --system --gid $CONTRAIL_GID $CONTRAIL_USER

COPY *.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
