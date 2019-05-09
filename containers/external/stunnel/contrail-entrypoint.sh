#!/bin/bash -e
stunnel /etc/stunnel/stunnel.conf
exec  "$@"
