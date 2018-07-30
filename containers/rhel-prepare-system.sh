#!/bin/bash -e
# Internal script. Preforms RHEL system registration, repo enabling, etc

if [[ "${RHEL_FORCE_REGISTRATION,,}" != 'false' ]] ; then
  echo "INFO: unregister system to force registration"
  subscription-manager unregister || true
fi

if ! subscription-manager status | grep -q -i 'Overall Status: Current' ; then
  register_opts=""
  [ -n "$RHEL_USER_NAME" ] && register_opts+=" --username $RHEL_USER_NAME"
  [ -n "$RHEL_USER_PASSWORD" ] && register_opts+=" --password $RHEL_USER_PASSWORD"
  [ -n "$ORG_KEY" ] && register_opts+=" --org $ORG_KEY"
  [ -n "$RHEL_ACTIVATION_KEY" ] && register_opts+=" --activationkey $RHEL_ACTIVATION_KEY"
  echo "INFO: register system with opts $register_opts"
  subscription-manager register $register_opts
  attach_opts='--auto'
  if [[ -n "$RHEL_POOL_ID" ]] ; then
    attach_opts="--pool $RHEL_POOL_ID"
  fi
  echo "INFO: attach subscription: ${attach_opts##--}"
  subscription-manager attach $attach_opts

  repos_list="${RHEL_HOST_REPOS//,/ }"
  repos_opts=''
  for r in $repos_list ; do
    repos_opts+=" --enable=$r"
  done
  echo "INFO: enable repos: $repos_list"
  subscription-manager repos $repos_opts
fi
