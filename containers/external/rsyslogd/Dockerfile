ARG CONTAINER_NAME
ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG RSYSLOG_VERSION=8.24.0
ARG VENDOR_DOMAIN

LABEL name=$CONTAINER_NAME \
    summary="Contrail rsyslogd" \
    description="Contrail rsyslogd support"

COPY *.sh /

RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    yum -y install rsyslog-$RSYSLOG_VERSION && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    find / -name '__pycache__' -delete -o -name "*.pyc" -delete -o -name "*.pyo" -delete

# Copy configuration files
COPY rsyslog.conf /etc/
COPY rsyslog.d/*.conf /etc/rsyslog.d/

ENV RSYSLOGD_PIDFILE=/var/run/rsyslogd.pid
ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD rsyslogd -n -f /etc/rsyslog.conf -i $RSYSLOGD_PIDFILE

ENV SERVICE_NAME=rsyslogd
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
