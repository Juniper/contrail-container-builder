ARG CONTRAIL_REGISTRY=localhost:5000
ARG CONTRAIL_CONTAINER_TAG=4.1.0.0-6-newton
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

COPY entrypoint.sh /
COPY contrail-entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
