FROM centos:7.5.1804

COPY repos/build/install/usr/bin/contrail-named /usr/bin/
COPY repos/build/install/usr/bin/contrail-rndc /usr/bin/

# TODO: command and user under whom this stuff is running should probably be changed
CMD "/usr/bin/contrail-named -c /etc/contrail/dns/contrail-named.conf"
