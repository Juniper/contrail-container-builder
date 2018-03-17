#!/bin/bash -e

if [ -f /usr/bin/contrail-status ]; then
   exec "$@"
   return $?
fi

cat > /usr/bin/contrail-status << EOM
#!/bin/bash
docker run -it --rm --name contrail-status -v /etc/contrail:/etc/contrail -v /usr/bin:/usr/bin -v /var/run/docker.sock:/var/run/docker.sock --pid host --net host --privileged ${CONTRAIL_REPOSITORY}/contrail-status:${CONTRAIL_CONTAINER_TAG}
EOM

chmod +x /usr/bin/contrail-status

exec "$@"
