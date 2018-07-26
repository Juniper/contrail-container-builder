FROM redis:4.0.2 

ARG CONTAINER_NAME
COPY *.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]

ENV SERVICE_NAME=redis
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
