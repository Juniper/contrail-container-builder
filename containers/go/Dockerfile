FROM alpine:3.7

RUN apk update && apk upgrade && \
    apk add --no-cache rpm

COPY entrypoint.sh /

RUN yum install -y contrail && \
    yum clean all -y && \
    rm -rf /var/cache/yum

CMD ["contrail", "-c", "/etc/contrail/apisrv.yml"]
ENTRYPOINT ["/entrypoint.sh"]