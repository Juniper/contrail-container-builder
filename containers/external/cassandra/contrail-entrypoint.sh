#!/bin/bash -e

source /common.sh

CONFIG=/etc/cassandra/cassandra.yaml
JVM_OPTIONS_CONFIG=/etc/cassandra/jvm.options
change_variable()
{
  local VARIABLE_NAME=$1
  local VARIABLE_VALUE=$2
  sed -i "s/.*\($VARIABLE_NAME\):.*\([0-9a-z]\)/\1: $VARIABLE_VALUE/g" $CONFIG
}

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
#set heap size options directly to jvm.options to avoid possible duplicates
echo "INFO: JVM_EXTRA_OPTS=$JVM_EXTRA_OPTS"
for yaml in Xmx Xms ; do
  opt=$(echo $JVM_EXTRA_OPTS | sed -n "s/.*\(-${yaml}[0-9]*[mMgG]\).*/\1/p")
  if [[ -n "${opt}" ]] ; then
    #remove opt from JVM_EXTRA_OPTS and put it to config file
    JVM_EXTRA_OPTS=$(echo $JVM_EXTRA_OPTS | sed "s/-${yaml}[0-9]*[mMgG]//g")
    sed -i "s/^[#]*-${yaml}.*/${opt}/g" $JVM_OPTIONS_CONFIG
  fi
done

export JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Dcassandra.rpc_port=${CASSANDRA_PORT} \
  -Dcassandra.native_transport_port=${CASSANDRA_CQL_PORT} \
  -Dcassandra.ssl_storage_port=${CASSANDRA_SSL_STORAGE_PORT} \
  -Dcassandra.storage_port=${CASSANDRA_STORAGE_PORT} \
  -Dcassandra.jmx.local.port=${CASSANDRA_JMX_LOCAL_PORT}"

if is_enabled $CASSANDRA_SSL_ENABLE ; then
  jks_dir='/usr/local/lib/cassandra/conf'
  mkdir -p $jks_dir

  rm -f ${jks_dir}/server-truststore.jks ${jks_dir}/server-keystore.jks
  keytool -keystore ${jks_dir}/server-truststore.jks \
          -keypass ${CASSANDRA_SSL_KEYSTORE_PASSWORD} -storepass ${CASSANDRA_SSL_TRUSTSTORE_PASSWORD} \
          -noprompt \
          -alias CARoot -import -file ${CASSANDRA_SSL_CA_CERTFILE}
  openssl pkcs12 -export -in ${CASSANDRA_SSL_CERTFILE} \
          -inkey ${CASSANDRA_SSL_KEYFILE} \
          -chain -CAfile ${CASSANDRA_SSL_CA_CERTFILE} \
          -password pass:${CASSANDRA_SSL_TRUSTSTORE_PASSWORD} -name $(hostname -f) -out TmpFile
  keytool -importkeystore -deststorepass ${CASSANDRA_SSL_KEYSTORE_PASSWORD} \
          -destkeypass ${CASSANDRA_SSL_KEYSTORE_PASSWORD} \
          -destkeystore ${jks_dir}/server-keystore.jks -deststoretype pkcs12 \
          -srcstorepass ${CASSANDRA_SSL_TRUSTSTORE_PASSWORD} -srckeystore TmpFile \
          -srcstoretype PKCS12 -alias $(hostname -f)

  # remove encryption sections
  cp $CONFIG $CONFIG.bak
  cat $CONFIG.bak | awk 'NR==1{flag=1} {if(flag==0 && substr($0,1,1)!=" "){flag=1}; if($1=="client_encryption_options:"||$1=="server_encryption_options:"){flag=0}; if(flag==1){print($0)}}' > $CONFIG
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

# apply client encryption
client_encryption_options:
    enabled: ${CASSANDRA_SSL_ENABLE}
    keystore: ${jks_dir}/server-keystore.jks
    keystore_password: ${CASSANDRA_SSL_KEYSTORE_PASSWORD}
    # For local access to run cqlsh on a local node with SSL encryption, require_client_auth can be set to false
    require_client_auth: false
    # Set trustore and truststore_password if require_client_auth is true
    truststore: ${jks_dir}/server-truststore.jks
    truststore_password: ${CASSANDRA_SSL_TRUSTSTORE_PASSWORD}
    protocol: ${CASSANDRA_SSL_PROTOCOL}
    algorithm: ${CASSANDRA_SSL_ALGORITHM}
    store_type: JKS
    cipher_suites: ${CASSANDRA_SSL_CIPHER_SUITES}
EOF
  # prepare settings for cqlsh
  cat >/root/.cqlshrc << EOM
[ssl]
certfile = $CASSANDRA_SSL_CA_CERTFILE
EOM

fi

#explicitly set 
cat <<EOF >>$CONFIG
#change datafile directory
data_file_directories:
     - ${CASSANDRA_LIB}/data
#change commitlog_directory
commitlog_directory: ${CASSANDRA_LIB}/commitlog
saved_caches_directory: ${CASSANDRA_LIB}/saved_caches
EOF


# Number of flush writers should match number of vCPUs if ssd disks are used
change_variable memtable_flush_writers ${CASSANDRA_CONFIG_MEMTABLE_FLUSH_WRITER}
# For compaction operation there is a need for more capacity
change_variable concurrent_compactors ${CASSANDRA_CONFIG_CONCURRECT_COMPACTORS}
change_variable compaction_throughput_mb_per_sec ${CASSANDRA_CONFIG_COMPACTION_THROUGHPUT_MB_PER_SEC}
# Increasing throughput for writes and reads
change_variable concurrent_reads ${CASSANDRA_CONFIG_CONCURRECT_READS}
change_variable concurrent_writes ${CASSANDRA_CONFIG_CONCURRECT_WRITES}
# We are reducing GC pressure
change_variable memtable_allocation_type ${CASSANDRA_CONFIG_MEMTABLE_ALLOCATION_TYPE}

# patch loggin options
declare -A log_levels_map=( [SYS_DEBUG]='DEBUG' [SYS_INFO]='INFO' [SYS_NOTICE]='INFO' [SYS_ERROR]="ERROR" )
log_level=${log_levels_map[$LOG_LEVEL]}
if [ -n "$log_level" ] ; then
  sed -i "s/\(<logger.*org.apache.cassandra.*level=\"\).*\(\".*\)/\1${log_level}\2/g" /etc/cassandra/logback.xml
fi

echo "INFO: CASSANDRA_SEEDS=$CASSANDRA_SEEDS CASSANDRA_LISTEN_ADDRESS=$CASSANDRA_LISTEN_ADDRESS JVM_EXTRA_OPTS=$JVM_EXTRA_OPTS"
echo "INFO: exec /docker-entrypoint.sh $@"

exec /docker-entrypoint.sh "$@"
