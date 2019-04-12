FROM rabbitmq:3.6.10-management

LABEL summary="RabbitMQ server" \
	  description="The message bus that different process subscribe to" \
	
ARG CONTAINER_NAME

# due to changes in debian repos apt-transport-https is needed for
# update but it can't be installed without update. thus error in
# first update should be ignored.
RUN apt-get update || /bin/true && \
         apt-get -fy install bind9-host

COPY *.sh hostname_to_ip /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["rabbitmq-server"]

ENV SERVICE_NAME=rabbitmq
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
