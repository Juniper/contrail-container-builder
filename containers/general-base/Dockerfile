# This is the general base for all: non-contrail specfic like external and for contrail specific

FROM centos:7.4.1708

# this copy should be before yum install
COPY *.repo /etc/yum.repos.d/

RUN yum update -y && \
    yum install -y yum-plugin-priorities https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y iproute less

COPY *.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
