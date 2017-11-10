#!/bin/bash
currentVersion=$1
newVersion=$2
if [ -z $1 ]; then
    echo "need repo version"
    exit
fi
while IFS= read -r line; do 
 file=`echo $line|awk -F":" '{print $1}'`
 sed -i "s/$currentVersion/$newVersion/g" $file
done < <(grep -r "${currentVersion}" .)
