FROM redis:4.0.14
ARG VENDOR_NAME
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail Redis" \
      description="Contrail Redis server supports query engine."

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

COPY *.sh hostname_to_ip /
RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    /upgrade_pkgs.sh

ENTRYPOINT ["/contrail-entrypoint.sh"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=redis
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
