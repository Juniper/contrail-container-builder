FROM haproxy:1.7
ARG CONTAINER_NAME

COPY *.sh /

RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' 

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["haproxy","-f","/usr/local/etc/haproxy/haproxy.cfg"]

ENV SERVICE_NAME=tsn_haproxy
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
