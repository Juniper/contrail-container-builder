FROM centos:7.5.1804

# This is needed for cassandra-cpp-driver
COPY build-container/*.repo /etc/yum.repos.d

# TODO: resolve each dependency of ldd to a library to ensure they all are installed
# From default system only boost and cassandra-cpp-driver is missing
RUN yum -y install epel-release \
&& yum update -y \
&& yum install -y \
    boost \
    cassandra-cpp-driver \
&& yum clean all \
&& rm -rf /var/cache/yum

COPY repos/build/install/usr/lib/*.so* /usr/lib/
RUN ldconfig

COPY repos/build/install/usr/bin/contrail-dns /usr/bin/
COPY repos/build/install/usr/bin/contrail-rndc /usr/bin/

CMD ["/usr/bin/contrail-dns", "--conf_file", "/etc/contrail/contrail-dns.conf"]
