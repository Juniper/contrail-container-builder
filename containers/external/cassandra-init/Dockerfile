FROM alpine:latest

COPY entrypoint.sh /
COPY contrail-entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
