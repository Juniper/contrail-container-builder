FROM opencontrailnightly/contrail-base:latest

RUN yum install -y contrail-nodemgr python-pip && \
    pip install docker && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY contrail-status.py /root
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/bin/python /root/contrail-status.py

LABEL net.juniper.contrail=contrail-status
