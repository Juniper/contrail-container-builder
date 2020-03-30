FROM cassandra:3.11.3
ARG VENDOR_NAME
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ENV CONTAINER_NAME $CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail Cassandra DB" \
      description="Configuration database for Contrail Controller."

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

COPY *.sh /
RUN bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    /upgrade_pkgs.sh

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["cassandra", "-f"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=cassandra
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
