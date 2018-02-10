FROM alpine:latest

ARG CONTRAIL_REPOSITORY
ARG CONTRAIL_VERSION

RUN apk add --update py2-pip rpm && \
    pip install netaddr requests && \
    curl ${CONTRAIL_REPOSITORY}/ && \
    wget -nv ${CONTRAIL_REPOSITORY}/python-contrail-${CONTRAIL_VERSION}.el7.centos.x86_64.rpm ${CONTRAIL_REPOSITORY}/contrail-utils-${CONTRAIL_VERSION}.el7.centos.x86_64.rpm && \
    rpm -i --nodeps *.rpm && \
    rm *.rpm && \
    apk del rpm

CMD ["/bin/bash"]
