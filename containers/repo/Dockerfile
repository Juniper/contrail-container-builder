ARG LINUX_DISTR=centos
ARG LINUX_DISTR_VER=7
FROM $LINUX_DISTR:$LINUX_DISTR_VER

ARG CONTAINER_NAME
ARG CONTRAIL_CONTAINER_TAG
LABEL vendor="Juniper" \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail container builder repository."\
      description="The image contains Contrail Container Builder repository and generates Kubernetes manifest for Contrail installation. Required parameters in common.env file: PHYSICAL_INTERFACE, HOST_IP. Mandatory variable KUBE_MANIFEST which must be passed to 'docker run' command "

COPY __licensing.txt /licenses/licensing.txt

RUN yum install -y git iproute && git clone https://github.com/Juniper/contrail-container-builder
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]