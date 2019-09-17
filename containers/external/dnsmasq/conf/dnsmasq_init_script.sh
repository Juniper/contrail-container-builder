#!/bin/bash
if [ ${1} = init ] ; then
     echo "SCRIPT INIT"
     python dnsmasq_lease_processing.py read
else
     echo "SCRIPT ADD"
     if [ ${1} = old ] || [ ${1} = add ] ; then
         echo ${2} ${3}
         python dnsmasq_lease_processing.py write ${2} ${3}
     fi
fi
