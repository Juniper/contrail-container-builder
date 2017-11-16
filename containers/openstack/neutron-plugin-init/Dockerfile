FROM centos:7.3.1611

ARG REPOSITORY=http://10.0.2.15/contrail
RUN printf "[contrail] \nname = Contrail repo \nbaseurl = $REPOSITORY \nenabled = 1 \ngpgcheck = 0\n" >> /etc/yum.repos.d/contrail.repo \
  && echo "export TERM=xterm" >> ~/.bashrc

RUN yum update -y && yum install -y \
    neutron-plugin-contrail \
  && yum clean all

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
