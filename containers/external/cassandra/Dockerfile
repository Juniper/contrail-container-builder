FROM cassandra:3.11.1

ARG CONTAINER_NAME

COPY contrail-entrypoint.sh /
COPY cassandra-health.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["cassandra", "-f"]

LABEL net.juniper.contrail.service=cassandra
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
