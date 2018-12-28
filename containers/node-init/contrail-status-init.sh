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

if [ -f /host/usr/bin/contrail-status ]; then
   exit
fi

vol_opts='-v /var/run/docker.sock:/var/run/docker.sock'
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
  fi
fi

# cause multiple instances can generate this at one moment - this operation should be atomic
# TODO: it is expected that ssl dirs are byt default, it is needed to detect dirs and
# do mount volumes appropriately
tmp_file=/host/usr/bin/contrail-status.tmp
cat > $tmp_file << EOM
#!/bin/bash -e
docker run --rm --name contrail-status $vol_opts --pid host --net host --privileged ${CONTRAIL_STATUS_IMAGE}
EOM

chmod 755 $tmp_file
mv -f $tmp_file /host/usr/bin/contrail-status
