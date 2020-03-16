FROM rabbitmq:3.7.20-management
ARG VENDOR_NAME
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail RabbitMQ" \
      description="Contrail Rabbitmq is the message bus that different Contrail processes subscribe to."

# These definitions are just for build purposes and must not be changed at runtime
ENV CONTRAIL_GID=1999 \
    CONTRAIL_USER=contrail

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

COPY *.sh hostname_to_ip /

# due to changes in debian repos apt-transport-https is needed for
# update but it can't be installed without update. thus error in
# first update should be ignored.
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update || /bin/true && \
    apt-get -fy install bind9-host xxd && \
    /upgrade_pkgs.sh && \
    groupadd --gid $CONTRAIL_GID --system $CONTRAIL_USER && \
    /bin/bash -c "source /common.sh" \
    usermod -a -G $CONTRAIL_GID $RABBITMQ_USER

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["rabbitmq-server"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=rabbitmq
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
