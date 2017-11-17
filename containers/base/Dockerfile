FROM centos:7.3.1611

ARG REPOSITORY=http://10.0.2.15/contrail
ARG OPENSTACK_VERSION=ocata
ARG OPENSTACK_SUBVERSION=3
RUN printf "[contrail] \nname = Contrail repo \nbaseurl = $REPOSITORY \nenabled = 1 \ngpgcheck = 0\n" >> /etc/yum.repos.d/contrail.repo \
  && echo "export TERM=xterm" >> ~/.bashrc

RUN yum update -y && \
    yum install -y \
      yum-plugin-priorities \
      http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm \
      https://repos.fedorapeople.org/repos/openstack/openstack-${OPENSTACK_VERSION}/rdo-release-${OPENSTACK_VERSION}-${OPENSTACK_SUBVERSION}.noarch.rpm && \
    yum install -y iproute less contrail-lib contrail-setup contrail-utils python-contrail && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig

# ldconfig looks strange. contrail-lib installs shared libraries but do not call it...

COPY *.sh /

CMD ["/usr/bin/tail","-f","/dev/null"]
