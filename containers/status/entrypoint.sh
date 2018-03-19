#!/bin/bash -e

if [ -f /usr/bin/contrail-status ]; then
   exec "$@"
   return $?
fi

source /version
cat > /usr/bin/contrail-status << EOM
#!/bin/bash
docker run -it --rm --name contrail-status -v /etc/contrail:/etc/contrail -v /usr/bin:/usr/bin -v /var/run/docker.sock:/var/run/docker.sock --pid host --net host --privileged ${CONTAINER_REGISTRY}/contrail-status:${CONTRAIL_VERSION}
EOM

chmod +x /usr/bin/contrail-status

exec "$@"
