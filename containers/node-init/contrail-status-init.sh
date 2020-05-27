#!/bin/bash

source /common.sh

if [[ ! -d /host/usr/bin ]]; then
  echo "ERROR: there is no mount /host/usr/bin from Host's /usr/bin. Utility contrail-status could not be created."
  exit 1
fi

if [[ -z "$CONTRAIL_STATUS_IMAGE" ]]; then
  echo 'ERROR: variable $CONTRAIL_STATUS_IMAGE is not defined. Utility contrail-status could not be created.'
  exit 1
fi

env_opts=''
vol_opts=''
# ssl folder is always to mounted: in case of IPA init container
# should not generate cert and is_ssl_enabled is false for this container,
# certs&keys are generated by IPA
vol_opts+=' -v /etc/contrail/ssl:/etc/contrail/ssl:ro'
vol_opts+=' -v /etc/hosts:/etc/hosts:ro'
vol_opts+=' -v /etc/localtime:/etc/localtime:ro'
if [[ -n "${SERVER_CA_CERTFILE}" ]] ; then
  # In case of FreeIPA CA file is palced in /etc/ipa/ca.crt
  # and should be mounted additionally
  if [[ ! "${SERVER_CA_CERTFILE}" =~ "/etc/contrail/ssl" ]] ; then
    vol_opts+=" -v ${SERVER_CA_CERTFILE}:${SERVER_CA_CERTFILE}:ro"
    env_opts+="-e CONTRAIL_STATUS_OPTS='--cacert ${SERVER_CA_CERTFILE}'"
  fi
fi

# cause multiple instances can generate this at one moment - this operation should be atomic
# TODO: it is expected that ssl dirs are byt default, it is needed to detect dirs and
# do mount volumes appropriately
tmp_file=/host/usr/bin/contrail-status.tmp
tmp_suffix="${CONTRAIL_STATUS_IMAGE} /root/contrail-status.py ${CONTRAIL_STATUS_OPTS} \$@"
cat > $tmp_file << EOM
#!/bin/bash -e
u=\$(which docker 2>/dev/null)
if ((\$? == 0)); then
    \$u run --rm --name \${CONTRAIL_STATUS_CONTAINER_NAME:-contrail-status} -v /var/run/docker.sock:/var/run/docker.sock $vol_opts $env_opts --pid host --net host --privileged $tmp_suffix
    exit \$?
fi
u=\$(which podman 2>/dev/null)
if ((\$? == 0)); then
    r="\$u run --rm --name \${CONTRAIL_STATUS_CONTAINER_NAME:-contrail-status} $vol_opts $env_opts --net host --privileged"
    r+=' --volume=/var/run/crio/crio.sock:/var/run/crio/crio.sock'
    r+=' --volume=/sys/fs/selinux:/sys/fs/selinux --volume=/var/lib/containers:/var/lib/containers'
    r+=' --volume=/var/run/libpod:/var/run/libpod --volume=/run/runc:/run/runc'
    r+=' --volume=/sys/fs/cgroup/:/sys/fs/cgroup/ --cap-add=ALL --security-opt seccomp=unconfined --pid host'
    \$r $tmp_suffix
    exit \$?
fi
EOM

chmod 755 $tmp_file
mv -f $tmp_file /host/usr/bin/contrail-status
