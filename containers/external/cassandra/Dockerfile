FROM cassandra:3.11.1

COPY contrail-entrypoint.sh /

ENTRYPOINT ["/contrail-entrypoint.sh"]
CMD ["/docker-entrypoint.sh", "cassandra", "-f"]

LABEL net.juniper.nodemgr.filter.name=contrail-database
LABEL net.juniper.contrail=cassandra
LABEL net.juniper.node=database
