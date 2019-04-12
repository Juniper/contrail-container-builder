FROM redis:4.0.2 

LABEL summary="Redis Server" \
	  description="Redis server supports query engine and caches UVEs." \
	
ARG CONTAINER_NAME

COPY *.sh hostname_to_ip /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/contrail-entrypoint.sh"]

ENV SERVICE_NAME=redis
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
