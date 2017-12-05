FROM ${CONTRAIL_REGISTRY}/contrail-controller-database-base:${CONTRAIL_VERSION}

RUN yum install -y redis

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-server","/etc/redis.conf"]
