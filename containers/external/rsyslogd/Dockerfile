FROM centos:7
ARG CONTAINER_NAME
ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
ARG RSYSLOG_VERSION=8.1907.0-2.el7

LABEL vendor="Juniper" \
    version=$CONTRAIL_CONTAINER_TAG \
    release="5.1.0" \
    name=$CONTAINER_NAME \
    summary="Contrail rsyslogd" \
    description="Contrail rsyslogd support"

RUN yum -y install wget \
    && cd /etc/yum.repos.d/ \
    && wget http://rpms.adiscon.com/v8-stable/rsyslog.repo
RUN yum -y install iproute rsyslog-${RSYSLOG_VERSION}

# Add required license as text file in Liceses directory
RUN mkdir -p /licenses
COPY __licensing.txt /licenses/licensing.txt

COPY *.sh /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

RUN mkdir -p /etc/contrail/rsyslog.d
# Copy configuration files
COPY rsyslog.conf /etc/contrail/
COPY rsyslog.d/*.conf /etc/contrail/rsyslog.d/

EXPOSE 514

ENTRYPOINT ["/contrail-entrypoint.sh"]

ENV SERVICE_NAME=rsyslogd
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
