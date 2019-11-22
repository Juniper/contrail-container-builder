#!/bin/bash
/bin/bash -c 'for item in `ls /__*` ; do mv $item /${item:3} ; done'
