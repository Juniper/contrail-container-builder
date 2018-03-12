#!/bin/bash

if [ -f /usr/bin/contrail-status ]; then
   exec "$@"
   return 0
fi

cat > /usr/bin/contrail-status << EOM
#!/bin/bash
docker run -it --rm --name contrail-status -v /etc/contrail:/etc/contrail -v /usr/bin:/usr/bin -v /var/run:/var/run --pid host --net host --privileged contrail-status:latest
EOM

chmod +x /usr/bin/contrail-status

exec "$@"
