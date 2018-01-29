FROM centos:7.4.1708

MAINTAINER Pawel Kopka <pawel.kopka@codilime.com>

RUN yum install -y epel-release && \
    yum install -y openvpn && \
    yum clean all && \
    rm -rf /var/cache/yum

VOLUME ["/etc/multicloud/openvpn/", "/etc/multicloud/ssl/"]

CMD ["/usr/sbin/openvpn"]

