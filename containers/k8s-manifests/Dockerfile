FROM scratch

ARG VENDOR_NAME
ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail container builder repository." \
      description="The container generates Kubernetes manifest for Contrail installation and contains Contrail Container Builder repository."

COPY __licensing.txt /licenses/licensing.txt
COPY __contrail-container-builder /contrail-container-builder
