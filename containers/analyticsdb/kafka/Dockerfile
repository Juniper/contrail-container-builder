FROM centos:7.3.1611

ARG DISTRO_NAME=kafka_2.11-0.9.0.1
ENV KAFKA_DIR=/opt/$DISTRO_NAME \
    KAFKA_CONF_DIR=/opt/$DISTRO_NAME/config

RUN yum install -y java iproute \
  && yum clean all

RUN curl -o $DISTRO_NAME.tgz http://www-us.apache.org/dist/kafka/0.9.0.1/$DISTRO_NAME.tgz \
  && tar -xvf $DISTRO_NAME.tgz \
  && mv $DISTRO_NAME /opt/$DISTRO_NAME \
  && rm $DISTRO_NAME.tgz

WORKDIR /opt/$DISTRO_NAME

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bin/kafka-server-start.sh", "config/server.properties"]
