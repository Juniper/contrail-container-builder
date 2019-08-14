FROM rabbitmq:3.6.10-management
ARG VENDOR_NAME
ARG PROJECT_DOMAIN

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail RabbitMQ" \
      description="Contrail Rabbitmq is the message bus that different Contrail processes subscribe to."

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

# due to changes in debian repos apt-transport-https is needed for
# update but it can't be installed without update. thus error in
# first update should be ignored.
RUN apt-get update || /bin/true && \
         apt-get -fy install bind9-host xxd

COPY *.sh hostname_to_ip /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["rabbitmq-server"]

ENV SERVICE_NAME=rabbitmq
LABEL $PROJECT_DOMAIN".service"=$SERVICE_NAME
LABEL $PROJECT_DOMAIN".container.name"=$CONTAINER_NAME
