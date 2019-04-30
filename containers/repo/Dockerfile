ARG LINUX_DISTR=centos
ARG LINUX_DISTR_VER=7
FROM $LINUX_DISTR:$LINUX_DISTR_VER

ARG CONTAINER_NAME
LABEL name=$CONTAINER_NAME \
      summary="Contrail container builder repository."\
      description="The image contains Contrail Container Builder repository and generates Kubernetes manifest for Contrain installation. Required parameters in common.env file: PHYSICAL_INTERFACE, HOST_IP, KUBE_MANIFEST."

RUN yum install -y git && git clone https://github.com/Juniper/contrail-container-builder
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]