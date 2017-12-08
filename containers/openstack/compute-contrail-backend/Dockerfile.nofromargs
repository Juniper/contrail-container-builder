FROM centos:7.4.1708

ARG REPOSITORY=http://10.0.2.15/contrail
RUN printf "[contrail] \nname = Contrail repo \nbaseurl = $REPOSITORY \nenabled = 1 \ngpgcheck = 0\n" >> /etc/yum.repos.d/contrail.repo \
  && echo "export TERM=xterm" >> ~/.bashrc

RUN yum update -y && \
    yum install -y iproute less contrail-vrouter-agent && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
