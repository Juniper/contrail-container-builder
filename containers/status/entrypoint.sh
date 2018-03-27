#!/bin/bash -e

if [ -f /host/usr/bin/contrail-status ]; then
   exec "$@"
   exit
fi

echo "This script takes environment variable IMAGE to create /usr/bin/contrail-status file."
echo "If this variable is empty or absent then script tries to detect it."
echo "But there is no exact method to do it - if you want to be sure"
echo "then please pass IMAGE from outside by addind '--env IMAGE=' with IMAGE_ID"
echo "to 'docker run' string for this container."
my_image="${IMAGE}"
if [[ -z "$my_image" ]]; then
  my_id=`grep ':.*memory.*:' /proc/self/cgroup | head -1 | grep -oE "[0-9a-fA-F]{64}"`
  if [[ -n "$my_id" ]]; then
    my_image=`python -c "import docker; client = docker.from_env(); print(str(client.inspect_container('$my_id')['Config']['Image']))" 2>/dev/null`
    if [[ -n "$my_image" ]]; then
      cat > /host/usr/bin/contrail-status << EOM
#!/bin/bash -e
docker run --rm --name contrail-status -v /usr/bin:/host/usr/bin -v /var/run/docker.sock:/var/run/docker.sock --pid host --net host --privileged $my_image
EOM
    chmod +x /host/usr/bin/contrail-status
    fi
  fi
fi
if [ ! -f /host/usr/bin/contrail-status ]; then
  echo "Self docker image couldn't be found. Please provide IMAGE variable from outside to create /usr/bin/contrail-status file."
fi

exec "$@"
