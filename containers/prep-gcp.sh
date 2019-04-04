#!/bin/bash -ex
# Internal script.
# only for GCP private project
# Adds GCP repository, installs google-cloud-sdk, configures docker authorization for Google cloud marketplace.

linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')

sudo -u root /bin/bash << EOS
case "${linux}" in
  "ubuntu" )
    # Create environment variable for correct distribution
    export CLOUD_SDK_REPO="cloud-sdk-$(cat /etc/os-release | grep "ID=" | sed -e 's/ID=//g')"
    # Add the Cloud SDK distribution URI as a package source
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
    # Import the Google Cloud Platform public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    # Update the package list and install the Cloud SDK
    apt-get -y update && apt-get -y install google-cloud-sdk
    ;;
  "centos" | "rhel" )
    tee /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
    yum install -y google-cloud-sdk
    ;;
esac
# https://cloud.google.com/sdk/gcloud/reference/auth/activate-service-account
gcloud auth activate-service-account --key-file=$GCP_KEY_JSON
gcloud -q auth configure-docker
EOS
