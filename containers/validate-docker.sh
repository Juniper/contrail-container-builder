#!/bin/bash -e
# Internal script. Validates docker deployment

linux=$(awk -F"=" '/^ID=/{print $2}' /etc/os-release | tr -d '"')

function install_docker () {
  case "${linux}" in
    "ubuntu" )
      sudo apt-get install -y docker.io
      ;;
    "centos" | "rhel" )
      sudo yum install -y docker
      sudo systemctl enable docker
      sudo systemctl start docker
      ;;
  esac
}

hash docker 2>/dev/null || install_docker

docker_ver=$(docker -v | awk -F' ' '{print $3}' | sed 's/,//g')

if [[ $docker_ver > "17.06" ]] ; then
  exit
fi

# TODO: The code of docker patching below (after 'if') makes docker broken on ubuntu 14.04
if [[ "$LINUX_ID" != "ubuntu" || "$LINUX_VER_ID" > "14.04" ]] ; then
  exit
fi

echo "Installed docker version $docker_ver is smaller than the one required for parametrized Dockerfiles"

echo "Load docker binaries"
tgz_file=$(mktemp)
curl -s -o $tgz_file https://download.docker.com/linux/static/stable/x86_64/docker-17.06.2-ce.tgz
tmp_dir=$(mktemp -d)
tar xzvf $tgz_file -C $tmp_dir

echo "Replace docker binaries"
sudo service docker stop
sudo cp $tmp_dir/docker/* /usr/bin/
sudo service docker start

rm $tgz_file
rm -rf $tmp_dir
