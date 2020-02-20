ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG CONTAINER_NAME
ARG CONTRAIL_BUILD_FROM_SOURCE
LABEL name=$CONTAINER_NAME \
      summary="Contrail Device Manager" \
      description="Contrail Device Manager is used to manage network devices in the Contrail system."

# git rpm cannot be remove as it removes contrail-utils, and common by deps
RUN pip install --no-compile "ansible==2.6.13" "attrs==19.3.0" "bcrypt==3.1.7" "cffi==1.14.0" "colorama==0.4.3" "configparser==4.0.2 " "contextlib2==0.6.0.post1 " "cryptography==2.8" "enum34==1.1.6 " "functools32==3.2.3.post2 " "future==0.18.2" "icdiff==1.9.1" "importlib-metadata==1.5.0 " "inflection==0.3.1" "ipaddress==1.0.23 " "jinja2==2.11.1" "jsnapy==1.3.3" "jsonschema==3.2.0" "junos-eznc==2.2.0" "jxmlease==1.0.1" "lxml==4.5.0" "markdown==3.1.1" "markupsafe==1.1.1" "ncclient==0.6.3" "netaddr==0.7.19" "paramiko==2.7.1" "pathlib2==2.3.5 " "pycparser==2.19" "pynacl==1.3.0" "pyparsing==2.4.6" "pyrsistent==0.15.7" "pyserial==3.4" "python-jsonschema-objects==0.3.12" "pyyaml==5.3" "scandir==1.10.0 " "scp==0.13.2" "selectors2==2.0.1" "six==1.14.0" "timeout-decorator==0.4.1" "zipp==1.2.0" && \
    yum install -y git iputils && \
    ansible-galaxy install git+https://github.com/Juniper/ansible-junos-stdlib.git,909b3826f64326d21c7a3b0107be2e7dbc257a6c,Juniper.junos && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-device-manager", "--conf_file", "/etc/contrail/contrail-device-manager.conf", "--conf_file", "/etc/contrail/contrail-keystone-auth.conf"]

ENV SERVICE_NAME=device-manager
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME

