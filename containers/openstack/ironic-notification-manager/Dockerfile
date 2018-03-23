ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-centos7-newton
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG PYTHON_PIP_RPM=python-pip
ARG PYTHON_PIP_VENV=""

# TODO: change this to install pythin-amqp
# right now it's caused by https://bugzilla.redhat.com/show_bug.cgi?id=1357660 -
# python setup.py for ironic manager doesn't work in
RUN yum install -y $PYTHON_PIP_RPM && \
    if [[ -n "$PYTHON_PIP_VENV" ]] ; then \
        source $PYTHON_PIP_VENV ; \
    fi && \
    pip install amqp==1.4.7

RUN yum install -y ironic-notification-manager && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/ironic-notification-manager","--conf_file","/etc/contrail/ironic-notification-manager.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]

LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
