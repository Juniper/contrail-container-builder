BASE_EXTRA_RPMS=$(echo $BASE_EXTRA_RPMS | tr -d '"' | tr ',' ' ')
if [[ -n "$BASE_EXTRA_RPMS" ]] ; then 
    echo "INFO: contrail-base: install $BASE_EXTRA_RPMS"
    yum install -y $BASE_EXTRA_RPMS
    echo "INFO: importing gpg keys from any newly installed repos"
    [ -d /etc/pki/rpm-gpg ] && rpm --import /etc/pki/rpm-gpg/*
fi