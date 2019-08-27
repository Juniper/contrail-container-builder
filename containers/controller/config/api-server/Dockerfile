ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-base:${CONTRAIL_CONTAINER_TAG}
RUN git clone https://github.com/Juniper/contrail-api-client.git &&\
    cd contrail-api-client && \
	 scons
RUN easy_install pip &&\
	 pip install build/production/api-lib/dist/contrail-api-client-*.tar.gz
