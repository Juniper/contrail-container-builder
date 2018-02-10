FROM alpine:latest

ARG CONTRAIL_REPOSITORY
ARG REPO_PRIMARY

RUN apk add --update py2-pip rpm curl && \
    pip install netaddr requests && \
    set -x && \
    pall=$(curl -Ls ${CONTRAIL_REPOSITORY}/${REPO_PRIMARY} | gunzip | grep -P "<name>|<location") && \
    pc=$(echo "$pall" | grep -A 1 "<name>python-contrail<" | tail -1 | sed -e 's/^.*"\(.*.rpm\)".*$/\1/') && \
    cu=$(echo "$pall" | grep -A 1 "<name>contrail-utils<" | tail -1 | sed -e 's/^.*"\(.*.rpm\)".*$/\1/') && \
    wget -nv ${CONTRAIL_REPOSITORY}/$pc ${CONTRAIL_REPOSITORY}/$cu && \
    rpm -i --nodeps *.rpm && \
    rm *.rpm && \
    apk del rpm curl

CMD ["/bin/bash"]
