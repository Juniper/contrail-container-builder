ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail Kubernetes manifests and scripts to deploy Contrail" \
      description="Required parameters in common.env file: PHYSICAL_INTERFACE, HOST_IP, KUBE_MANIFEST. Example command to generate contrail.yaml and get all scripts and manifests: docker run -d --rm -v $WORKING_DIR:/manifests_temp --env-file common.env $KUBE_MANIFESTS_IMAGE "

COPY manifests_utils /manifests_utils/

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

ENV NODE_TYPE=kubernetes
ENV SERVICE_NAME=kubernetes-manifests

LABEL net.juniper.contrail.pod=$NODE_TYPE
LABEL net.juniper.contrail.service=$SERVICE_NAME
LABEL net.juniper.contrail.container.name=$CONTAINER_NAME