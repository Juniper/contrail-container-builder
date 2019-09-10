FROM centos:7.5.1804

# TODO: resolve each dependency of ldd to a library to ensure they all are installed
# From default system only boost is missing for vrouter-agent
RUN yum -y install epel-release \
&& yum update -y \
&& yum install -y \
    boost \
&& yum clean all \
&& rm -rf /var/cache/yum

# Not sure this is right because of ldconfig warnings, and that some file seems ending up in /lib
COPY repos/build/lib/libtcmalloc.so* repos/build/lib/liblog4cplus-1.1.so* repos/build/lib/libtbb.so* /usr/lib/
RUN ldconfig

COPY repos/build/install/usr/bin/contrail-vrouter-agent /usr/bin/

CMD ["/usr/bin/contrail-vrouter-agent", "--conf_file", "/etc/contrail/contrail-vrouter-agent.conf"]
