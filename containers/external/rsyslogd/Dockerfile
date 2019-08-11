ARG CONTAINER_NAME
ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG RSYSLOG_VERSION=8.24.0-34.el7

LABEL vendor="Juniper" \
    version=$CONTRAIL_CONTAINER_TAG \
    release="5.1.0" \
    name=$CONTAINER_NAME \
    summary="Contrail rsyslogd" \
    description="Contrail rsyslogd support"

COPY *.sh /

RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    mkdir -p /licenses && \
    yum -y install rsyslog-${RSYSLOG_VERSION} && \
    yum clean all -y && \
    rm -rf /var/cache/yum

# Add required license as text file in licenses directory
COPY __licensing.txt /licenses/licensing.txt

# Copy configuration files
COPY rsyslog.conf /etc/
COPY rsyslog.d/*.conf /etc/rsyslog.d/

ENTRYPOINT ["/contrail-entrypoint.sh"]

ENV SERVICE_NAME=rsyslogd
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
