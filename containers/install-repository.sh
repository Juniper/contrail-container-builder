#!/bin/bash

export OUSER=$(id -u)
export OGROUP=$(id -g)

package_root_dir="/var/www"
linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')

sudo -u root /bin/bash << EOS

case "${linux}" in
  "ubuntu" )
    apt-get update
    apt-get install -y lighttpd rpm2cpio
    ln -s /etc/lighttpd/conf-available/10-dir-listing.conf /etc/lighttpd/conf-enabled/
    ;;
  "centos" | "rhel" )
    # yum install -y epel-release
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum install -y lighttpd
    sed -i 's/\(dir-listing.activate\)[ \t]*=.*/\1 = "enable"/' /etc/lighttpd/conf.d/dirlisting.conf
    sed -i 's/server.use-ipv6.*=.*enable.*/server.use-ipv6 = "disable"/g' /etc/lighttpd/lighttpd.conf
    ;;
esac
sed -i 's#\(server.document-root\)[ \t]*=.*#\1 = "'$package_root_dir'"#' /etc/lighttpd/lighttpd.conf
service lighttpd restart
chown -R $OUSER /var/www
chgrp -R $OGROUP /var/www

EOS

contrail_version=${CONTRAIL_VERSION:-'4.0.1.0-32'}
os_versions=(ocata newton pike)
s3_bucket_url="https://s3-us-west-2.amazonaws.com/contrailrhel7"

for os_version in ${os_versions[@]}:
do
  package_url=$s3_bucket_url'/contrail-install-packages-'$contrail_version'~'$os_version'.el7.noarch.rpm'
  http_status=$(curl -Isw "%{http_code}" -o /dev/null $package_url)
  if [ $http_status == "200" ]; then
    break
  fi
done

if [ $http_status != "200" ]; then
  echo 'No Contrail packages found for version '$contrail_version
  exit
fi

package_fname=$(mktemp)
echo Getting $package_url to $package_fname
curl -o $package_fname $package_url

package_dir=$(mktemp -d)
pushd $package_dir
rpm2cpio $package_fname | cpio -idmv
popd

if [ -n $CONTRAIL_REPOSITORY ]; then
  dir_prefix=$(echo $CONTRAIL_REPOSITORY | awk -F'/' '{print $4}' | sed 's/'$version'$//')
fi
repo_dir=$package_root_dir'/'$dir_prefix$contrail_version
if [ -d $repo_dir ]; then
  echo 'Remove existing packages in '$repo_dir
  rm -rf $repo_dir
fi
echo 'Extract packages to '$repo_dir
mkdir $repo_dir
tar -xvzf $package_dir'/opt/contrail/contrail_packages/contrail_rpms.tgz' -C $repo_dir

# unpack vrouter.ko
pushd $package_dir
rpm2cpio "$repo_dir/contrail-vrouter-${CONTRAIL_VERSION}.el7.x86_64.rpm" | cpio -idmv
popd
#TODO: detect directory name with kernel version
cp "$package_dir/opt/contrail/vrouter-kernel-modules/3.10.0-327.10.1.el7.x86_64/vrouter.ko" "${repo_dir}/"

rm -rf $package_dir
rm $package_fname
