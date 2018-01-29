FROM ubuntu:latest

MAINTAINER Pawel Kopka <pawel.kopka@codilime.com>

RUN apt-get update && \
    apt-get install -y openvpn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/etc/vpnaas/openvpn/"]
VOLUME ["/etc/vpnaas/ssl/"]

CMD ["openvpn"]

