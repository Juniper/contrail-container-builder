FROM ubuntu:latest

MAINTAINER Pawel Kopka <pawel.kopka@codilime.com>

RUN apt-get update && apt-get install -y openvpn

VOLUME ["/etc/vpnaas/openvpn/"]
VOLUME ["/etc/vpnaas/ssl/"]

CMD ["openvpn"] 
