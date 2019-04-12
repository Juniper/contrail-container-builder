FROM cassandra:3.11.3

ARG CONTAINER_NAME

LABEL summary="Cassandra DB" \
	  description="Cassandra DB is used as system DB. \n\
	              The config, system logs, process and module messages and flow level data are stored in different keyspaces within Cassandra. " \
	
COPY *.sh /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["cassandra", "-f"]

ENV SERVICE_NAME=cassandra
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
