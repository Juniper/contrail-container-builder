#!/bin/bash -ex
# Internal script. Installs HTTP server for local packages repository. Takes package_root_dir from environment (/var/www by
# default)

OUSER=$(id -u)
OGROUP=$(id -g)
linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')

sudo -u root /bin/bash << EOS
case "${linux}" in
  "ubuntu" )
    apt-get -y update &>>$HOME/apt.log
    apt-get install -y lighttpd rpm2cpio createrepo reprepro rng-tools gnupg2 &>>$HOME/apt.log
    rm -f /etc/lighttpd/conf-enabled/10-dir-listing.conf
    ln -s /etc/lighttpd/conf-available/10-dir-listing.conf /etc/lighttpd/conf-enabled/
    ;;
  "centos" | "rhel" )
    # yum install -y epel-release
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum install -y lighttpd createrepo
    sed -i 's/\(dir-listing.activate\)[ \t]*=.*/\1 = "enable"/' /etc/lighttpd/conf.d/dirlisting.conf
    sed -i 's/server.use-ipv6.*=.*enable.*/server.use-ipv6 = "disable"/g' /etc/lighttpd/lighttpd.conf
    ;;
esac
sed -i 's#\(server.document-root\)[ \t]*=.*#\1 = "'$package_root_dir'"#' /etc/lighttpd/lighttpd.conf
service lighttpd restart
chown -R $OUSER:$OGROUP $package_root_dir
EOS
