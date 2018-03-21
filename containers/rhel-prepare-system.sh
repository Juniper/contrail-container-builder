#!/bin/bash -e
# Internal script. Preforms RHEL system registration, repo enabling, etc

if ! subscription-manager status | grep -q -i 'Overall Status: Current' ; then
  echo "INFO: unregister system if registered by a chance"
  subscription-manager unregister || true
  register_opts=""
  [ -n "$RHEL_USER_NAME" ] && register_opts+=" --username $RHEL_USER_NAME"
  [ -n "$RHEL_USER_PASSWORD" ] && register_opts+=" --password $RHEL_USER_PASSWORD"
  [ -n "$ORG_KEY" ] && register_opts+=" --org $ORG_KEY"
  [ -n "$RHEL_ACTIVATION_KEY" ] && activationkey+=" --org $RHEL_ACTIVATION_KEY"
  echo "INFO: register system with opts $register_opts"
  subscription-manager register $register_opts
  attach_opts='--auto'
  if [[ -n "$RHEL_POOL_ID" ]] ; then
    attach_opts="--pool $RHEL_POOL_ID"
  fi
  echo "INFO: attach subscription: ${attach_opts##--}"
  subscription-manager attach $attach_opts
fi

repos_opts='--enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-optional-rpms'
for r in ${RHEL_EXTRA_REPOS//,/ } ; do
  repos_opts+=" --enable=$r"
done
echo "INFO: enable repos: rhel-7-server-rpms rhel-7-server-extras-rpms rhel-7-server-optional-rpms ${RHEL_EXTRA_REPOS//,/ }"
subscription-manager repos $repos_opts
