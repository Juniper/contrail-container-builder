#!/bin/bash -e

function assert_var() {
  local var_name=$1
  if [[ -z "${!var_name}" ]] ; then
    echo "ERROR: env variable is unset $var_name"
    exit -1
  fi
}

assert_var LINUX_DISTR
assert_var LINUX_DISTR_VER
assert_var LINUX_DISTR_SERIES
assert_var CONTRAIL_INSTALL_PACKAGES_URL
assert_var repo_dir

# create gpg key for repository
if ! output=$(gpg --list-keys contrail@juniper.net) ; then
  contrail_repo_key_cfg=$(mktemp)
  cat > $contrail_repo_key_cfg <<EOF
    %echo Generating a basic OpenPGP key
    Key-Type: default
    Subkey-Type: default
    Subkey-Length: 1024
    Name-Real: Contrail
    Name-Comment: Contrail
    Name-Email: contrail@juniper.net
    Expire-Date: 0
    %no-protection
    %commit
    %echo done
EOF
  sudo rngd -r /dev/urandom
  gpg2 --batch --gen-key $contrail_repo_key_cfg
fi
contrail_repo_key=$(mktemp)
gpg --export -a contrail@juniper.net > $contrail_repo_key
GPGKEYID=$(gpg --list-keys --keyid-format LONG contrail@juniper.net | grep "^pub" | awk '{print $2}' | cut -d / -f2)

# setup repository
whoami_user=$(whoami)
sudo -u root /bin/bash << EOS
set -e
cd $repo_dir
rm -rf ./ubuntu
mkdir -p ./ubuntu/{conf,dists,incoming,indices,logs,pool,project,tmp}
cp "$contrail_repo_key" ./ubuntu/contrail.key
gpg --no-default-keyring --keyring ./ubuntu/contrail.gpg --import ./ubuntu/contrail.key

chown -R $whoami_user:$whoami_user ./ubuntu
chmod -R a+r ./ubuntu

cd ./ubuntu
cat > ./conf/distributions <<EOF
Origin: Contrail
Label: Base Contrail packages
Codename: $LINUX_DISTR_SERIES
Architectures: i386 amd64 source
Components: main
Description: Description of repository you are creating
SignWith: $GPGKEYID
EOF

cat > ./conf/options <<EOF
ask-passphrase
basedir .
EOF

for ff in \$(ls ../*.deb) ; do
  echo "Adding \$ff into $LINUX_DISTR_SERIES"
  reprepro includedeb $LINUX_DISTR_SERIES \$ff
  rm -f \$ff
done
EOS
