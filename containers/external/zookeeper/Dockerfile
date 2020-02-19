FROM zookeeper:3.4.14
ARG VENDOR_NAME
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail Zookeeper" \
      description="Contrail uses the Apache ZooKeeper process to maintain synchronization of Contrail configuration, analytics and database running on the different instances of controllers."

# These definitions are just for build purposes and must not be changed at runtime
ENV CONTRAIL_GID=1999 \
    CONTRAIL_USER=contrail \
    ZOOKEEPER_USER=zookeeper \
    SERVICE_NAME=$ZOOKEEPER_USER

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

COPY *.sh hostname_to_ip /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    /upgrade_pkgs.sh && \
    groupadd --gid $CONTRAIL_GID --system $CONTRAIL_USER && \
    usermod -a -G $CONTRAIL_GID $ZOOKEEPER_USER 

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
