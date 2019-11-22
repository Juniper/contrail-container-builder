#!/bin/bash
chown -R $CONTRAIL_USER:$CONTRAIL_USER /usr/src/contrail
/bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'
