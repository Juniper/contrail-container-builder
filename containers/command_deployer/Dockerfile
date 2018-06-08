# Dockerfile for building Ansible image for Alpine 3, with as few additional software as possible.
#
# @see https://github.com/gliderlabs/docker-alpine/blob/master/docs/usage.md
#
# Version  1.0
#


# pull base image
FROM alpine:3.6

MAINTAINER Nitish Krishna 

RUN echo "===> Installing sudo to emulate normal OS behavior..."  && \
    apk --update add sudo                                         && \
    \
    apk --update add python py-pip openssl ca-certificates jq bash && \
    apk --update add --virtual build-dependencies \
                python-dev libffi-dev openssl-dev build-base && \
    apk --update add sshpass openssh-client rsync git && \
    pip install --upgrade pip cffi boto boto3 ansible==2.4.3.0 pywinrm apache-libcloud pycrypto && \
    \
    echo "===> Removing package list..."  && \
    apk del build-dependencies            && \
    rm -rf /var/cache/apk/*               && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible                        && \
    echo 'localhost' > /etc/ansible/hosts        && \
    git config --global user.email "contrail@juniper.net" && \
    git config --global user.name "Contrail Deployer" && \
    git clone http://github.com/Juniper/contrail-command-deployer /contrail-command-deployer

COPY entrypoint.sh /
COPY configure_command_servers /bin
COPY deploy_contrail_command /bin
ENTRYPOINT ["/entrypoint.sh"]
# default command: display Ansible version
CMD [ "/bin/deploy_contrail_command" ]
