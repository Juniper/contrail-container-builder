#!/bin/bash -x

source /common.sh

if ! is_enabled "$SSL_ENABLE" ; then
  echo "INFO: SSL_ENABLE=$SSL_ENABLE, nothing to do"
  exit 0
fi

function fail() {
  local msg="$@"
  echo "ERROR: $msg"
  exit -1
}

common_name=$DEFAULT_HOSTNAME

alt_names="DNS.1 = $(hostname -f)"
alt_name_num=2
for ip in $(get_local_ips) ; do
  alt_names+="\nDNS.${alt_name_num} = $ip"
  (( alt_name_num+=1 ))
done

[[ -z "$SERVER_CA_CERTFILE" && -z "$SERVER_CA_KEYFILE" ]] \
  || [[ -n "$SERVER_CA_CERTFILE" && -n "$SERVER_CA_KEYFILE" ]] \
  || fail "SERVER_CA_CERTFILE and SERVER_CA_KEYFILE must be either both empty or both set"

working_dir='/tmp/contrail_ssl_gen'
ca_file="${SERVER_CA_CERTFILE}"
if [[ -z "${ca_file}" || ! -f "${ca_file}" ]] ; then
  ca_file="$working_dir/certs/ca.crt.pem"
fi
ca_key_file=${SERVER_CA_KEYFILE}
if [[ -z "${ca_key_file}" || ! -f "${ca_key_file}" ]] ; then
  ca_key_file="$working_dir/certs/ca.key.pem"
fi

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
countryName = US
stateOrProvinceName = California
localityName = Sannyvale
0.organizationName = OpenContrail
commonName = $common_name

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
private_key       = $ca_key_file
certificate       = $ca_file
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

[ v3_ca]
# Extensions for a typical CA
# PKIX recommendation.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = CA:true

[ crl_ext ]
authorityKeyIdentifier=keyid:always,issuer:always
EOF
cat "$openssl_config_file"

mkdir -p $(dirname $SERVER_CERTFILE)
mkdir -p $(dirname $SERVER_KEYFILE)

#generate local self-signed CA if requested
if [[ ! -f "${ca_file}" && ! -f "${ca_key_file}" ]] ; then
  openssl genrsa -out $ca_key_file 4096 || fail "Failed to generate CA key file"
  chmod 600 $ca_key_file || fail "Failed to to chmod 600 on $ca_key_file"
  openssl req -config $openssl_config_file -new -x509 -days 365 -extensions v3_ca -key $ca_key_file -out $ca_file || fail "Failed to generate CA cert"
  chmod 644 $ca_file || fail "Failed to chmod 644 on $ca_file"
else
  [[ -f "${ca_file}" && -f "${ca_key_file}" ]] || fail "'${ca_file}' or '${ca_key_file}' doesnt exist"
fi

# generate server certificate
csr_file="${working_dir}/server.pem.csr"
openssl genrsa -out $SERVER_KEYFILE 2048 || fail "Failed to generate server key file $SERVER_KEYFILE"
chmod 600 $SERVER_KEYFILE || fail "Failed to chmod 600 on $SERVER_KEYFILE"
openssl req -config $openssl_config_file -key $SERVER_KEYFILE -new  -out $csr_file || fail "Failed to create CSR"
yes | openssl ca -config $openssl_config_file -extensions v3_req -days 365 -in $csr_file -out $SERVER_CERTFILE || fail "Failed to sign certificate"
chmod 644 $SERVER_CERTFILE || fail "Failed to chmod 644 on $SERVER_CERTFILE"
