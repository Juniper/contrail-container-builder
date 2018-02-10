FROM alpine:latest

ARG CONTRAIL_REPOSITORY
ARG CONTRAIL_VERSION
ARG REPO_PRIMARY

RUN apk add --update py2-pip rpm curl && \
    pip install netaddr requests && \
    pc=`curl -Ls ${CONTRAIL_REPOSITORY}/${REPO_PRIMARY} | gunzip | grep "<location.*python-contrail-${CONTRAIL_VERSION}" | sed -e 's/^.*"\(.*.rpm\)".*$/\1/'` && \
    cu=`curl -Ls ${CONTRAIL_REPOSITORY}/${REPO_PRIMARY} | gunzip | grep "<location.*contrail-utils-${CONTRAIL_VERSION}" | sed -e 's/^.*"\(.*.rpm\)".*$/\1/'` && \
    wget -nv ${CONTRAIL_REPOSITORY}/$pc ${CONTRAIL_REPOSITORY}/$cu && \
    rpm -i --nodeps *.rpm && \
    rm *.rpm && \
    apk del rpm curl

CMD ["/bin/bash"]
