#!/bin/bash -ex

dockerfiles='dockerfiles'
mapped_dockerfiles_file='mapped_dockerfiles_file'

image_parent_is_mapped () {
  #collect mapped images from previous levels
  local image2check=$1
  local image2check_parent=$(cat $image2check | grep -v '^#' |  grep 'FROM ${CONTRAIL_REGISTRY}' |  cut -f2 -d/  | cut -f1 -d: )
  for mapped_dockerimage in $(cat $dir/$mapped_dockerfiles_file 2>/dev/null | cut -f 2 -d ' ') ; do
    if [[ "$mapped_dockerimage" == "$image2check_parent" ]]; then
      echo 1
    fi
  done
}

function new_level()  {
  local current_level=$1
  local has_next_level=0
  for x in $(cat $dir/$dockerfiles | cut -d ' ' -f 1); do
    image_parent=$(cat $(echo $x | cut -d ' ' -f 1 ) | grep 'FROM ${CONTRAIL_REGISTRY}')
    is_mapped=$(image_parent_is_mapped $x)
    #check if dependencies are empty or are matched in $mapped_dorckerfiles
    if [[ $image_parent == '' || $is_mapped == 1 ]] ; then
      #remove appropriate line from $dockerfiles and write image adress to $mapped_dockerfiles and level.N files
      grep -s "^$x" $dir/$dockerfiles >> $dir/level.$current_level
      grep -v "^$x" $dir/$dockerfiles >> $dir/$dockerfiles.tmp
      mv $dir/dockerfiles.tmp $dir/$dockerfiles
    fi
  done

  cat $dir/level.$current_level >> $dir/$mapped_dockerfiles_file

  #break loop when all dockerfiles are mapped
  if [[ $(cat $dir/$dockerfiles | wc -l) == '0' ]]; then
    has_next_level=1
  fi
  echo $has_next_level
}

function create_dockerfiles_map() {
  for image in $(find * -name "Dockerfile"); do
    image_name=$(echo $image | sed -e 's/^/contrail-/g' | sed -e 's/\//-/g' | sed -e 's/-Dockerfile//g')
    echo $image $image_name >> $dir/$dockerfiles
  done
}

# main func
rm -rf container_map_tmp.*
dir=$(mktemp -d container_map_tmp.XXX)
level=1
create_dockerfiles_map
br=0
while [[ $br == 0 ]]; do
  br=$(new_level $level)
  level=$((level+1))
done
