#!/bin/bash
[ -x "$(command -v ansible-galaxy)" ] && ansible-galaxy install git+https://github.com/Juniper/ansible-junos-stdlib.git,,Juniper.junos
yum remove -y git
