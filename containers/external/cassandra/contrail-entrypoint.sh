#!/bin/bash -e

source /common.sh

# In all in one deployment there is the race between vhost0 initialization
# and own IP detection, so there is 10 retries
for i in {1..10} ; do
  my_ip=$(find_my_ip_and_order_for_node_list "$CASSANDRA_SEEDS" | cut -d ' ' -f 1)
  if [ -n "$my_ip" ]; then
    break
  fi
  sleep 1
done

if [ -z "$my_ip" ]; then
  echo "ERROR: Cannot find self ips ('$(get_local_ips)') in Cassandra nodes ('$CASSANDRA_SEEDS')"
  exit -1
fi

# use first two servers as seeds
export CASSANDRA_SEEDS=$(echo $CASSANDRA_SEEDS | cut -d ',' -f 1,2)
export CASSANDRA_LISTEN_ADDRESS=$my_ip
export CASSANDRA_RPC_ADDRESS=$my_ip

export JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Dcassandra.rpc_port=${CASSANDRA_PORT} \
  -Dcassandra.native_transport_port=${CASSANDRA_CQL_PORT} \
  -Dcassandra.ssl_storage_port=${CASSANDRA_SSL_STORAGE_PORT} \
  -Dcassandra.storage_port=${CASSANDRA_STORAGE_PORT} \
  -Dcassandra.jmx.local.port=${CASSANDRA_JMX_LOCAL_PORT}"

if is_enabled $CASSANDRA_SSL_ENABLE ; then
  jks_dir='/usr/local/lib/cassandra/conf'
  mkdir -p $jks_dir

  keytool -keystore ${jks_dir}/server-truststore.jks \
          -keypass ${CASSANDRA_SSL_KEYSTORE_PASSWORD} -storepass ${CASSANDRA_SSL_TRUSTSTORE_PASSWORD} \
          -noprompt \
          -alias CARoot -import -file ${CASSANDRA_SSL_CA_CERTFILE}
  openssl pkcs12 -export -in ${CASSANDRA_SSL_CERTFILE} \
          -inkey ${CASSANDRA_SSL_KEYFILE} \
          -chain -CAfile ${CASSANDRA_SSL_CA_CERTFILE} \
          -password pass:${CASSANDRA_SSL_KEYSTORE_PASSWORD} -name localhost -out TmpFile
  keytool -importkeystore -deststorepass ${CASSANDRA_SSL_KEYSTORE_PASSWORD} \
          -destkeystore ${jks_dir}/server-keystore.jks \
          -srcstorepass ${CASSANDRA_SSL_TRUSTSTORE_PASSWORD} -srckeystore TmpFile \
          -srcstoretype PKCS12 -alias localhost
  keytool -keystore ${jks_dir}/server-keystore.jks \
          -keypass ${CASSANDRA_SSL_KEYSTORE_PASSWORD} -storepass ${CASSANDRA_SSL_TRUSTSTORE_PASSWORD} \
          -noprompt \
          -alias CARoot -import -file ${CASSANDRA_SSL_CA_CERTFILE}

  CONFIG=/etc/cassandra/cassandra.yaml
  # remove encryption sections
  cp $CONFIG $CONFIG.sbak
  cat $CONFIG.bak | awk 'NR==1{flag=1} {if(flag==0 && $0!~/^[[:space:]]/){flag=1}; if($1=="server_encryption_options:"){flag=0}; if(flag==1){print($0)}}' > $CONFIG
  cat <<EOF >>$CONFIG

# apply server encryption
server_encryption_options:
    internode_encryption: all
    keystore: ${jks_dir}/server-keystore.jks
    keystore_password: ${CASSANDRA_SSL_KEYSTORE_PASSWORD}
    truststore: ${jks_dir}/server-truststore.jks
    truststore_password: ${CASSANDRA_SSL_TRUSTSTORE_PASSWORD}
    # More advanced defaults below:
    protocol: ${CASSANDRA_SSL_PROTOCOL}
    algorithm: ${CASSANDRA_SSL_ALGORITHM}
    store_type: JKS
    cipher_suites: ${CASSANDRA_SSL_CIPHER_SUITES}
    require_client_auth: true
EOF

# clients don't support SSL for cassandra
#   cat $CONFIG.bak | awk 'NR==1{flag=1} {if(flag==0 && $0!~/^[[:space:]]/){flag=1}; if($1=="client_encryption_options:"||$1=="server_encryption_options:"){flag=0}; if(flag==1){print($0)}}' > $CONFIG
## apply client encryption
#client_encryption_options:
#    enabled: ${CASSANDRA_SSL_ENABLE}
#    keystore: ${jks_dir}/server-keystore.jks
#    keystore_password: ${CASSANDRA_SSL_KEYSTORE_PASSWORD}
#    # For local access to run cqlsh on a local node with SSL encryption, require_client_auth can be set to false
#    require_client_auth: false
#    # Set trustore and truststore_password if require_client_auth is true
#    truststore: ${jks_dir}/server-truststore.jks
#    truststore_password: ${CASSANDRA_SSL_TRUSTSTORE_PASSWORD}
#    protocol: ${CASSANDRA_SSL_PROTOCOL}
#    algorithm: ${CASSANDRA_SSL_ALGORITHM}
#    store_type: JKS
#    cipher_suites: ${CASSANDRA_SSL_CIPHER_SUITES}

fi

echo "INFO: CASSANDRA_SEEDS=$CASSANDRA_SEEDS CASSANDRA_LISTEN_ADDRESS=$CASSANDRA_LISTEN_ADDRESS JVM_EXTRA_OPTS=$JVM_EXTRA_OPTS"
echo "INFO: exec /docker-entrypoint.sh $@"

exec /docker-entrypoint.sh "$@"
