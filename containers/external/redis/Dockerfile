ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME

LABEL name=$CONTAINER_NAME \
      summary="Contrail Redis" \
      description="Contrail Redis server supports query engine."

COPY *.sh hostname_to_ip /

RUN set -eux && for item in `ls /__*` ; do mv $item /${item:3} ; done && \
    yum install https://repo.ius.io/ius-release-el7.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y && \
    yum install redis40u.x86_64 perl -y && \
    usermod -a -G $CONTRAIL_GID redis && \
    yum remove epel-release ius-release -y && \
    yum clean all -y && rm -rf /var/cache/yum


RUN mkdir /data && chown redis:redis /data
VOLUME /data
WORKDIR /data

ENTRYPOINT ["/contrail-entrypoint.sh"]

EXPOSE 6379

CMD ["redis-server"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=redis
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
