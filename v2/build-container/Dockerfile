FROM centos:7.5.1804

ENV USER root
ENV HOME /root/
ENV CONTRAIL $HOME/contrail
ARG BRANCH=master
ARG LC_ALL=en_US.UTF-8
ARG LANG=en_US.UTF-8
ARG LANGUAGE=en_US.UTF-8

ENV LC_ALL=$LC_ALL
ENV LANG=$LANG
ENV LANGUAGE=$LANGUAGE

RUN mkdir -p $CONTRAIL
WORKDIR $CONTRAIL

# Install android repo
RUN curl -s https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo \
&&  chmod a+x /usr/bin/repo

# Inject repositories that we might need
COPY *.repo /etc/yum.repos.d

# Install basic packages
# Turn off "nodocs" in yum to enable documentation for developers.
RUN yum -y install epel-release \
&&  yum -y update \
&&  yum -y install \
    createrepo \
    docker \
    docker-python \
    gcc \
    gdb \
    git \
    make \
    python-devel \
    python-pip \
    python36-devel \
    python36-pip \
    rpm-build \
    vim \
    wget \
    yum-utils \
    bash-completion \
    bash-completion-extras \
    ShellCheck \
    man-pages \
    man-db \
&&  yum clean all \
&&  rm -rf /var/cache/yum

# Initialize sandbox, get code, install build dependencies
# and fetch third parties
RUN echo "Initializing repo from $BRANCH" \
&&  repo init --no-clone-bundle -q -u https://github.com/Juniper/contrail-vnc -b $BRANCH \
&&  repo sync --no-clone-bundle -q contrail-packages contrail-third-party \
&&  make -f tools/packages/Makefile dep \
&&  ./third_party/fetch_packages.py \
&&  yum clean all -y \
&&  rm -rf /var/cache/yum

# DEVELOPMENT ENVIRONMENT TWEAKS
# contrail-kubernetes and contrail-config
RUN pip install --upgrade future tox geventhttpclient

# Adding tools to support conversion to python3
RUN pip3 install --upgrade caniusepython3 future tox geventhttpclient

RUN echo export CONTRAIL=$CONTRAIL >> $HOME/.bashrc \
&&  echo export LD_LIBRARY_PATH=$CONTRAIL/build/lib >> $HOME/.bashrc

ADD Dockerfile $HOME/

