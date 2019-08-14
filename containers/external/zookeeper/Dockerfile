FROM zookeeper:3.4.10
ARG VENDOR_NAME
ARG PROJECT_DOMAIN

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail Zookeeper" \
      description="Contrail uses the Apache ZooKeeper process to maintain synchronization of Contrail configuration, analytics and database running on the different instances of controllers."

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

COPY *.sh hostname_to_ip /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]

ENV SERVICE_NAME=zookeeper
LABEL $PROJECT_DOMAIN".service"=$SERVICE_NAME
LABEL $PROJECT_DOMAIN".container.name"=$CONTAINER_NAME
