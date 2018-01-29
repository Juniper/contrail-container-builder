ARG OS_VERSION=latest

FROM centos:$OS_VERSION

MAINTAINER Pawel Kopka <pawel.kopka@codilime.com>

RUN yum install -y epel-release && \
    yum install -y openvpn && \
    yum clean all && \
    rm -rf /var/cache/yum

VOLUME ["/etc/multicloud/openvpn/", "/etc/multicloud/ssl/"]

CMD ["/usr/sbin/openvpn"]

