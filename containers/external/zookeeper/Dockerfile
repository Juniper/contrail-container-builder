FROM zookeeper:3.4.10

LABEL summary="zookeeper" \
	  description="zookeeper distributes SNMP polling across nodes." \
	
ARG CONTAINER_NAME

COPY *.sh hostname_to_ip /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]

ENV SERVICE_NAME=zookeeper
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
