#!/bin/bash
apt-get purge -y yum yum-utils rpm2cpio cpio
apt-get autoremove -y
rm -rf /etc/yum.repos.d
