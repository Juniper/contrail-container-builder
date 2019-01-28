#!/bin/bash

source /common.sh

CA_PRIVATE_KEY_BITS=${CA_PRIVATE_KEY_BITS:-4096}
PRIVATE_KEY_BITS=${PRIVATE_KEY_BITS:-2048}

if ! is_ssl_enabled ; then
  echo "INFO: No SSL Parameters Enabled, nothing to do"
  exit 0
fi

if [[ -z "$SERVER_CERTFILE" || -z "$SERVER_KEYFILE" ]] ; then
  msg="ERROR: one of mandatory paramters is not provided\n"
  msg+="       SERVER_CERTFILE='$SERVER_CERTFILE'\n"
  msg+="       SERVER_KEYFILE='$SERVER_KEYFILE'\n"
  echo -e "$msg"
  exit -1
fi

FORCE_GENERATE_CERT=${FORCE_GENERATE_CERT:-'false'}
if [[ -f "$SERVER_CERTFILE" && -f "$SERVER_KEYFILE" ]] ; then
  if ! is_enabled $FORCE_GENERATE_CERT ; then
    echo "INFO: cert and key files are already exist"
    exit 0
  fi
  echo "WARNING: cert and key files are already exist, but force generation is set"
fi

function fail() {
  local msg="$@"
  echo "ERROR: $msg"
  exit -1
}

cert_dir_name=$(dirname $SERVER_CERTFILE)
SERVER_CA_CERTFILE=${SERVER_CA_CERTFILE:-"$cert_dir_name/ca-cert.pem"}

mkdir -p $cert_dir_name
mkdir -p $(dirname $SERVER_KEYFILE)
mkdir -p $(dirname $SERVER_CA_CERTFILE)
grep -q -E "^contrail:" /etc/group || groupadd -g 1011 contrail
chgrp contrail $(dirname $SERVER_KEYFILE)
chmod 750 $(dirname $SERVER_KEYFILE)

tmp_lock_name=$(mktemp -p $cert_dir_name .lock.XXXXXXXX)
lock_file_name="${SERVER_CERTFILE}.lock"
if ! mv $tmp_lock_name $lock_file_name ; then
  # That is possible in cases of all-in-on deployments
  echo "WARNING: skip generation because some other init is in progress of that"
  exit 0
fi
trap "rm -f $lock_file_name ${SERVER_KEYFILE}.tmp ${SERVER_CERTFILE}.tmp ${SERVER_CA_CERTFILE}.tmp" EXIT

ca_provider=''
k8s_token_file=${K8S_TOKEN_FILE:-'/var/run/secrets/kubernetes.io/serviceaccount/token'}
k8s_ca_file=${K8S_CA_FILE:-'/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'}
if [[ -f "$k8s_token_file"  && -f "$k8s_ca_file" ]] ; then
  echo "INFO: K8S deployment, use K8S facilities for cert-generation"
  ca_provider='kubernetes'
fi

full_host_name="$(hostname -f)"
short_host_name="$(hostname -s)"

alt_name_num=1
alt_names="DNS.${alt_name_num} = $full_host_name"
(( alt_name_num+=1 ))
if [[ "$full_host_name" != "$short_host_name" ]] ; then
  alt_names+="\nDNS.${alt_name_num} = $short_host_name"
  (( alt_name_num+=1 ))
fi
if is_enabled $SELFSIGNED_CERTS_WITH_IPS ; then
  # start IP.x from 1
  alt_name_num=1
  for ip in $(get_local_ips) ; do
    if [[ "$ip" != '127.0.0.1' ]] ; then
      alt_names+="\nIP.${alt_name_num} = $ip"
      (( alt_name_num+=1 ))
    fi
  done
fi

working_dir='/tmp/contrail_ssl_gen'
SERVER_CA_KEYFILE=${SERVER_CA_KEYFILE:-"$working_dir/certs/ca.key.pem"}

rm -rf $working_dir
mkdir -p $working_dir/certs
touch ${working_dir}/index.txt ${working_dir}/index.txt.attr
echo 01 > ${working_dir}/serial.txt

openssl_config_file="${working_dir}/contrail_openssl.cfg"

cat <<EOF > $openssl_config_file
[req]
default_bits = 2048
prompt = no
default_md = sha256
default_days = 375
req_extensions = v3_req
distinguished_name = req_distinguished_name
x509_extensions = v3_ca

[ req_distinguished_name ]
commonName              = Contrail
countryName             = US
stateOrProvinceName     = CA
organizationName        = JuniperNetworks
organizationalUnitName  = JuniperCA
localityName            = Sunnyvale

[ v3_req ]
basicConstraints = CA:false
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ alt_names ]
$(echo -e $alt_names)

[ ca ]
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = $working_dir
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/certs
database          = \$dir/index.txt
serial            = \$dir/serial.txt
RANDFILE          = \$dir/.rand
# For certificate revocation lists.
crlnumber         = \$dir/crlnumber
crl               = \$dir/crl/crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30
# The root key and root certificate.
private_key       = $SERVER_CA_KEYFILE
certificate       = $SERVER_CA_CERTFILE
# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_optional

[ policy_optional ]
countryName            = optional
stateOrProvinceName    = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional
localityName           = optional

[ v3_ca]
# Extensions for a typical CA
# PKIX recommendation.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = CA:true

[ crl_ext ]
authorityKeyIdentifier=keyid:always,issuer:always
EOF
echo "INFO: openssl config file"
cat "$openssl_config_file"

function generate_local_ca() {
  #generate local self-signed CA if requested
  if [[ ! -f "${SERVER_CA_KEYFILE}" ]] ; then
    openssl genrsa -out $SERVER_CA_KEYFILE $CA_PRIVATE_KEY_BITS || fail "Failed to generate CA key file"
    chgrp contrail $SERVER_CA_KEYFILE || fail "Failed to set group contrail on $SERVER_CA_KEYFILE"
    chmod 640 $SERVER_CA_KEYFILE || fail "Failed to to chmod 640 on $SERVER_CA_KEYFILE"
    # it is needed always to re-create ca if new key is generated
    openssl req -config $openssl_config_file -new -x509 -days 365 -extensions v3_ca -key $SERVER_CA_KEYFILE -out $SERVER_CA_CERTFILE || fail "Failed to generate CA cert"
    chmod 644 $SERVER_CA_CERTFILE || fail "Failed to chmod 644 on $SERVER_CA_CERTFILE"
  fi
  [[ -f "${SERVER_CA_CERTFILE}" && -f "${SERVER_CA_KEYFILE}" ]] || fail "'${SERVER_CA_CERTFILE}' or '${SERVER_CA_KEYFILE}' doesnt exist"
}

if [[ "$ca_provider" != 'kubernetes' ]] ; then
  generate_local_ca
fi

# generate server certificate signing request
csr_file="${working_dir}/server.pem.csr"
openssl genrsa -out ${SERVER_KEYFILE}.tmp $PRIVATE_KEY_BITS || fail "Failed to generate server key file ${SERVER_KEYFILE}.tmp"
chmod 600 ${SERVER_KEYFILE}.tmp || fail "Failed to chmod 600 on ${SERVER_KEYFILE}.tmp"
openssl req -config $openssl_config_file -key ${SERVER_KEYFILE}.tmp -new  -out $csr_file || fail "Failed to create CSR"

function sign_csr_local_ca() {
  # sign csr by local CA
  yes | openssl ca -config $openssl_config_file -extensions v3_req -days 365 -in $csr_file -out ${SERVER_CERTFILE}.tmp || fail "Failed to sign certificate"
}

function sign_csr_k8s_ca() {
  # sign by K8S CA
  k8s_host=${KUBERNETES_API_SERVER:-${KUBERNETES_SERVICE_HOST:-${DEFAULT_LOCAL_IP}}}
  k8s_port=${KUBERNETES_API_PORT:-${KUBERNETES_PORT_443_TCP_PORT:-'6443'}}
  k8s_token=$(cat "$k8s_token_file")
  k8s_base_url="https://${k8s_host}:${k8s_port}/apis/certificates.k8s.io/v1beta1/certificatesigningrequests"
  k8s_cert_name="contrail-node.${full_host_name}"
  echo "INFO: base k8s curl url: $k8s_base_curl_opts"
  signing_request=$(cat $csr_file| base64 | tr -d '\n' | tr -d ' ')

  echo "INFO: K8S: remove old CSR if any"
  curl --cacert $k8s_ca_file -H "Authorization: Bearer $k8s_token" -X DELETE $k8s_base_url/${k8s_cert_name}

  echo "INFO: send new CSR for signing by K8S authority"
  curl --cacert $k8s_ca_file -H "Authorization: Bearer $k8s_token" -H "Content-Type: application/json" -X POST $k8s_base_url -d "
{
  \"apiVersion\": \"certificates.k8s.io/v1beta1\",
  \"kind\": \"CertificateSigningRequest\",
  \"metadata\": {
    \"name\": \"${k8s_cert_name}\"
  },
  \"spec\": {
    \"groups\": [
      \"system:authenticated\"
    ],
    \"request\": \"$signing_request\",
    \"usages\": [
      \"digital signature\",
      \"key encipherment\",
      \"server auth\"
    ]
  }
}"

  echo "INFO: approve CSR"
  curl --cacert $k8s_ca_file -H "Authorization: Bearer $k8s_token" -H "Content-Type: application/json" -X PUT $k8s_base_url/${k8s_cert_name}/approval -d "
{
  \"apiVersion\": \"certificates.k8s.io/v1beta1\",
  \"kind\": \"CertificateSigningRequest\",
  \"metadata\": {
    \"name\": \"${k8s_cert_name}\"
  },
  \"spec\": {
    \"groups\": [
      \"system:authenticated\"
    ],
    \"request\": \"$signing_request\",
    \"usages\": [
      \"digital signature\",
      \"key encipherment\",
      \"server auth\"
    ]
  },
  \"status\": {
    \"conditions\": [
      {
        \"type\": \"Approved\",
        \"reason\": \"ContrailApprove\",
        \"message\": \"This CSR was approved by contrail-node-init approve.\"
      }
    ]
   }
}"

  echo "INFO: download approved certificate"
  csr_response=$(curl --cacert $k8s_ca_file -H "Authorization: Bearer $k8s_token" -H "Content-Type: application/json" ${k8s_base_url}/${k8s_cert_name})

  if ! echo "$csr_response" | grep -q '"certificate":' ; then
    return 1
  fi
  echo "$csr_response" | awk '/"certificate":/{print($2)}' | tr -d '"' | base64 -d > ${SERVER_CERTFILE}.tmp
}

if [[ "$ca_provider" != 'kubernetes' ]] ; then
  sign_csr_local_ca
else
  if sign_csr_k8s_ca ; then
    # update CA file
    cp -f "$k8s_ca_file" "${SERVER_CA_CERTFILE}.tmp"
    mv "${SERVER_CA_CERTFILE}.tmp" "${SERVER_CA_CERTFILE}"
  else
    echo -e "WARNING: failed to sign CSR by K8S CA.\n"\
            "The Kubernetes controller responsible of approving the certificates could be disabled.\n"\
            "Fallback to local self-signed CA."
    generate_local_ca
    sign_csr_local_ca
  fi
fi

chmod 644 ${SERVER_CERTFILE}.tmp || fail "Failed to chmod 644 on ${SERVER_CERTFILE}.tmp"
mv ${SERVER_KEYFILE}.tmp ${SERVER_KEYFILE}
chgrp contrail $SERVER_KEYFILE || fail "Failed to set group contrail on $SERVER_CA_KEYFILE"
chmod 640 ${SERVER_KEYFILE} || fail "Failed to chmod 640 on ${SERVER_KEYFILE}"
mv ${SERVER_CERTFILE}.tmp ${SERVER_CERTFILE}
