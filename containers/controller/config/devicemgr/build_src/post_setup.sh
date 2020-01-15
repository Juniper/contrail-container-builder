#!/bin/bash
[ -x "$(command -v ansible-galaxy)" ] && ansible-galaxy install git+https://github.com/Juniper/ansible-junos-stdlib.git,,Juniper.junos
pip uninstall -y ansible
yum remove -y git
