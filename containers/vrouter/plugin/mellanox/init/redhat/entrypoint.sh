#!/bin/bash -e

# /lib/modules needs to be mounted.
yum --nogpgcheck -y install mstflint pciutils 

conf_enable()
{
  local mstdev=$1
  local config=$2

  mstconfig -d $mstdev --yes set ${config}=1
}

conf_query()
{
  local mstdev=$1
  local config=$2

  mstconfig -d $mstdev query ${config} 2> /dev/null | grep -w ${config} | awk '{print $NF}'
}

dev_reset()
{
  local mstdev=$1

  mstfwreset -d $mstdev --yes reset
}

for mlnx_device in `lspci -d 15b3: 2> /dev/null | awk '{print $1}'`
do
  case ${mlnx_device} in
    *\.0)
      val=`conf_query ${mlnx_device} "FLEX_PARSER_PROFILE_ENABLE"`
      if [ $val -eq 0 ]; then
        conf_enable ${mlnx_device} "FLEX_PARSER_PROFILE_ENABLE"
        if [ $? -eq 0 ]; then
          dev_reset ${mlnx_device}
        fi
      fi
      ;;
    *)
      continue
      ;;
  esac
done

exec $@
