ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG} as builder

MAINTAINER Pawel Kopka <pawel.kopka@codilime.com>

ENV STRONGSWAN_VERSION 5.6.1
ENV GPG_KEY DF42C170B34DBA77

RUN yum install -y epel-release \
        wget \
        tar \
        bzip2 \
        gcc \
        make \
        gmp-devel && \
    wget https://download.strongswan.org/strongswan-$STRONGSWAN_VERSION.tar.bz2.sig && \
    wget https://download.strongswan.org/strongswan-$STRONGSWAN_VERSION.tar.bz2 && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" && \
    gpg --batch --verify strongswan-$STRONGSWAN_VERSION.tar.bz2.sig strongswan-$STRONGSWAN_VERSION.tar.bz2 && \
    tar xjvf strongswan-$STRONGSWAN_VERSION.tar.bz2 && \
    ./strongswan-$STRONGSWAN_VERSION/configure --prefix=/usr --sysconfdir=/etc  && \
    make strongswan-$STRONGSWAN_VERSION/ && \
    make install strongswan-$STRONGSWAN_VERSION/

ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

COPY --from=builder /usr/libexec/ipsec/ /usr/libexec/ipsec/
COPY --from=builder /etc/ipsec.d /etc/ipsec.d
COPY --from=builder /etc/strongswan.d /etc/strongswan.d
COPY --from=builder /etc/swanctl /etc/swanctl
COPY --from=builder /usr/lib/ipsec /usr/lib/ipsec

RUN yum install -y epel-release \
        kmod \
        iproute

RUN ln -sf /etc/multicloud/strongswan/ipsec.conf /etc/ipsec.conf && \
    ln -sf /etc/multicloud/strongswan/ipsec.secrets /etc/ipsec.secrets && \
    ln -sf /etc/multicloud/strongswan/strongswan.conf /etc/strongswan.conf && \
    ln -sf /etc/multicloud/strongswan/stroke.conf /etc/strongswan.d/charon/stroke.conf && \
    ln -sf /etc/multicloud/ssl/CA.crt /etc/ipsec.d/cacerts/CA.crt && \
    ln -sf /etc/multicloud/ssl/HOST.crt /etc/ipsec.d/certs/HOST.crt && \
    ln -sf /etc/multicloud/ssl/HOST.key /etc/ipsec.d/private/HOST.key

VOLUME ["/etc/multicloud/strongswan/", "/etc/multicloud/ssl/", "/var/run/strongswan/"]

CMD ["/usr/libexec/ipsec/starter"]
