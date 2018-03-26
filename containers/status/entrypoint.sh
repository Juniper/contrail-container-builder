#!/bin/bash -e

if [ -f /host/usr/bin/contrail-status ]; then
   exec "$@"
   exit
fi

set -x
my_id=`grep -E "/docker.*[0-9a-fA-F]{8,}" /proc/self/cgroup | tail -1 | grep -oE '[0-9a-fA-F]{8,}'`
my_image=`python -c "import docker; client = docker.from_env(); print(str(client.inspect_container('$my_id')['Config']['Image']))"`
cat > /host/usr/bin/contrail-status << EOM
#!/bin/bash -e
docker run --rm --name contrail-status -v /usr/bin:/host/usr/bin -v /var/run/docker.sock:/var/run/docker.sock --pid host --net host --privileged $my_image
EOM

chmod +x /host/usr/bin/contrail-status

exec "$@"
