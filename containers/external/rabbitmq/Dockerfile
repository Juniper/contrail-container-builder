FROM rabbitmq:3.6.10

COPY contrail-entrypoint.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["/contrail-entrypoint.sh"]

LABEL net.juniper.contrail=rabbitmq
LABEL net.juniper.node=controller
