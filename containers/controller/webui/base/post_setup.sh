#!/bin/bash
ln -s /usr/lib64/node_modules /usr/src/contrail/contrail-web-core/node_modules
ln -s /usr/lib64/node_modules /usr/src/contrail/contrail-web-controller/node_modules
for item in `ls /__*` ; do
  mv $item /${item:3}
done
