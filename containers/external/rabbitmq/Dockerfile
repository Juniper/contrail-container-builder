FROM rabbitmq:3.6.10

COPY contrail-entrypoint.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["rabbitmq-server"]

LABEL net.juniper.contrail=rabbitmq
LABEL net.juniper.node=controller
