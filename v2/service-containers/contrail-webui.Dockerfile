FROM centos:7.5.1804

# This is needed for nodejs of specific version I guess
COPY build-container/*.repo /etc/yum.repos.d

# python-lxml is for running generateds.py
RUN yum -y install epel-release \
&& yum update -y \
&& yum install -y \
    nodejs-dev \
    make \
    python-lxml \
&& yum clean all \
&& rm -rf /var/cache/yum

COPY repos/src/contrail-api-client /usr/src/contrail/src/contrail-api-client

# Note 2:
# Somehow the following line doesn't create subdirs for contrail-web-core and others in /opt
#COPY repos/contrail-webui-third-party/ repos/contrail-web-core/ repos/contrail-web-controller/ /opt/
# So I have to do the following
COPY repos/contrail-webui-third-party /usr/src/contrail/contrail-webui-third-party
COPY repos/contrail-web-core /usr/src/contrail/contrail-web-core
COPY repos/contrail-web-controller /usr/src/contrail/contrail-web-controller


# Note: path '/usr/src/contrail' seems to actually matter (or one have to patch scripts and configs)
WORKDIR /usr/src/contrail/contrail-web-core

# Note 1: We already fetched dependencies, don't do it again
# Note 2: Seems that REPO=webController has some special meaning
# Note 3: No idea why upstream has 2 packages instead of one
RUN sed -i 's/\(python .*fetch_packages.py\)/#\1/' Makefile && \
  make package REPO=../contrail-web-controller,webController && \
  node src/tools/preParsePackage.js 'prod-env' . && \
  ln -s /usr/src/contrail/contrail-web-core/node_modules /usr/src/contrail/contrail-web-controller/node_modules

# Note about fetch_packages:
# if you want to run it in container you need to install following packages:
# wget unzip patch

# Note about ssh keys:
# you can generate some using ./generate_keys.sh script which uses openssl package

# Note about config files:
# /etc/contrail/config.global.js should be mounted to /usr/src/contrail/contrail-web-core/config/config.global.js
# /etc/contrail/contrail-webui-userauth.js should be mounted to /usr/src/contrail/contrail-web-core/config/userAuth.js
# (dst files are symlinks in the package)
#
# Note about commands. You need 2 containers from this image:
# 1. cmd: ["/usr/bin/node","jobServerStart.js"]
# 2. cmd: ["/usr/bin/node","webServerStart.js"]
