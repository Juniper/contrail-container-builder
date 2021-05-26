<<<<<<< HEAD   (2f574a fix url for get-pip.py)
FROM haproxy:1.7.11
=======
ARG HAPROXY_DISTR=haproxy
ARG HAPROXY_DISTR_VERSION=1.7
FROM $HAPROXY_DISTR:$HAPROXY_DISTR_VERSION
>>>>>>> CHANGE (1fac35 Build external container passing ARG's)
ARG VENDOR_NAME
ARG VENDOR_DOMAIN

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail HAProxy" \
      description="Contrail HAProxy supports high availability for Contrail container subsystems."

# Add required license as text file in Liceses directory
RUN mkdir /licenses
COPY __licensing.txt /licenses/licensing.txt

COPY *.sh /

ENV HAPROXY_GID=1999
ENV HAPROXY_UID=1999
ENV HAPROXY_USER=haproxy

RUN /bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done' && \
    groupadd --gid $HAPROXY_GID --system $HAPROXY_USER && \
    useradd --uid $HAPROXY_UID --no-create-home --shell /sbin/nologin --system --gid $HAPROXY_GID $HAPROXY_USER && \
    /upgrade_pkgs.sh

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=haproxy
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
