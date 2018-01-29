FROM centos:7.4.1708

MAINTAINER Pawel Kopka <pawel.kopka@codilime.com>

RUN yum install -y epel-release && \
    yum install -y bird && \
    yum clean all && \
    rm -rf /var/cache/yum


VOLUME ["/etc/multicloud/bird/", "/run/bird/"]

CMD ["/usr/sbin/bird"]
