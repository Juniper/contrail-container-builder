ARG CONTRAIL_REGISTRY
ARG CONTRAIL_CONTAINER_TAG
FROM ${CONTRAIL_REGISTRY}/contrail-general-base:${CONTRAIL_CONTAINER_TAG}
ARG VENDOR_DOMAIN
ARG VENDOR_NAME
ARG CONTAINER_NAME

LABEL vendor=$VENDOR_NAME \
      version=$CONTRAIL_CONTAINER_TAG \
      release="5.1.0" \
      name=$CONTAINER_NAME \
      summary="Contrail RabbitMQ" \
      description="Contrail Rabbitmq is the message bus that different Contrail processes subscribe to."

RUN curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash && \
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash && \
    yum install erlang-22.3* rabbitmq-server-3.8* bind bind-utils vim-common -y && \
    usermod -a -G $CONTRAIL_GID rabbitmq && \
    rabbitmq-plugins enable --offline rabbitmq_management && \ 
	erl -noinput -eval ' \
		{ ok, AdminBin } = zip:foldl(fun(FileInArchive, GetInfo, GetBin, Acc) -> \
			case Acc of \
				"" -> \
					case lists:suffix("/rabbitmqadmin", FileInArchive) of \
						true -> GetBin(); \
						false -> Acc \
					end; \
				_ -> Acc \
			end \
		end, "", init:get_plain_arguments()), \
		io:format("~s", [ AdminBin ]), \
		init:stop(). \
	' -- /plugins/rabbitmq_management-*.ez > /usr/local/bin/rabbitmqadmin && \
	[ -s /usr/local/bin/rabbitmqadmin ] && \
	chmod +x /usr/local/bin/rabbitmqadmin && \	
	rabbitmqadmin --version && \
    yum clean all -y && \
    rm -rf /var/cache/yum

COPY contrail-entrypoint.sh hostname_to_ip /
COPY docker-entrypoint.sh /usr/local/bin/

EXPOSE 15671 15672 4369 5671 5672 25672

ENTRYPOINT ["/contrail-entrypoint.sh"]

CMD ["rabbitmq-server"]

ENV CONTRAIL_VERSION=$CONTRAIL_CONTAINER_TAG
ENV SERVICE_NAME=rabbitmq
LABEL $VENDOR_DOMAIN".service"=$SERVICE_NAME
LABEL $VENDOR_DOMAIN".container.name"=$CONTAINER_NAME
