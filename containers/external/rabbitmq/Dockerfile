FROM rabbitmq:3.6.10-management

ARG CONTAINER_NAME

RUN apt-get update && apt-get -fy install bind9-host

COPY *.sh hostname_to_ip /
RUN /bin/bash -c 'for item in `ls __*` ; do mv $item ${item:2} ; done'

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["rabbitmq-server"]

ENV SERVICE_NAME=rabbitmq
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME
