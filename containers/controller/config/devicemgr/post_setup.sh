#!/bin/bash
[ -x "$(command -v ansible-galaxy)" ] && ansible-galaxy install Juniper.junos,2.3.0
