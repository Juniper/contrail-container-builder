# This is the base for contrail specific children

ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}

ARG BASE_EXTRA_RPMS=""

# note: ldconfig looks strange. contrail-lib installs shared libraries but do not call it...
RUN BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ') && \
    if [[ -n "$BASE_EXTRA_RPMS" ]] ; then \
        echo "INFO: contrail-base: install $BASE_EXTRA_RPMS" ; \
        yum install -y $BASE_EXTRA_RPMS ; \
    fi && \
<<<<<<< HEAD   (49a468 Set cassandra log level according to input settings)
    yum install -y iproute less hostname python3 python3-setuptools contrail-lib contrail-setup contrail-utils python-contrail && \
=======
    yum install -y iproute less hostname python2-setuptools wget && \
    wget -nv -c --tries=3 -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python2 /tmp/get-pip.py 'pip==20.1' && \
    if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
      yum install -y contrail-lib contrail-setup contrail-utils python-contrail ; \
    fi && \
    yum install -y python3 python3-setuptools && \
    python3 -m pip install --no-compile "future==0.18.2" "six==1.13.0" && \
>>>>>>> CHANGE (19d336 pip pip version)
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY *.sh /

ENV PS1="\033[1m($(printenv NODE_TYPE)-$(printenv SERVICE_NAME))\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "

CMD ["/usr/bin/tail","-f","/dev/null"]
