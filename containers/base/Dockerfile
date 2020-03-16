# This is the base for contrail specific children

ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG BASE_EXTRA_RPMS=""

# note: ldconfig looks strange. contrail-lib installs shared libraries but do not call it...
# note: we decide to install python3 packages by pip because they are absent in RHEL7/CentOS7 repos.
# these two packages (six, future) are installed here because they are needed for contrail-utils at least.
# further all deps should be moved to modules itself and here we must use requirements.txt to install deps.
# and one more next step is to install python modules from sources without creating RPM.
# WARNING! all pip deps must be installed with pinned version to avoid breakages when pypi is upgraded.
# WARNING! python2-setuptools is to be installed as it here below to get correct version -
#   from the yum repo install via BASE_EXTRA_RPMS. pip2 is to installed BEFORE python3 that installs pip3
#   byt dependencies.
# NOTE! all other deps must be installed in the container that requires such deps.
RUN BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ') && \
    if [[ -n "$BASE_EXTRA_RPMS" ]] ; then \
        echo "INFO: contrail-base: install $BASE_EXTRA_RPMS" ; \
        yum install -y $BASE_EXTRA_RPMS ; \
        echo "INFO: importing gpg keys from any newly installed repos" ; \
        [ -d /etc/pki/rpm-gpg ] && rpm --import /etc/pki/rpm-gpg/* ; \
    fi && \
    yum install -y iproute less hostname python2-setuptools wget && \
    wget -nv -c --tries=3 -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python2 /tmp/get-pip.py && \
    if [[ -z "$CONTRAIL_BUILD_FROM_SOURCE" ]] ; then \
      yum install -y contrail-lib contrail-setup contrail-utils python-contrail ; \
    fi && \
    yum install -y python3 python3-setuptools && \
    python3 -m pip install --no-compile "future==0.18.2" "six==1.13.0" && \
    yum clean all -y && \
    rm -rf /var/cache/yum && \
    ldconfig

COPY *.sh /

ENV PS1="\033[1m($(printenv NODE_TYPE)-$(printenv SERVICE_NAME))\033[m\017[$(id -un)@$(hostname -s) $(pwd)]$ "

CMD ["/usr/bin/tail","-f","/dev/null"]
