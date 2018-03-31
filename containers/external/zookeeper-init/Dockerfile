FROM alpine:latest

ARG CONTAINER_NAME

COPY entrypoint.sh /
COPY contrail-entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
