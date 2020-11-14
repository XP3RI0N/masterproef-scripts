#!/bin/bash
set -e

experimental=false

while [ $# -gt 0 ]
do
  case "$1" in
    --experimental)
      experimental=true
      ;;
    *)
      echo "Argument: $1 does not exist."
      ;;
  esac
  shift
done

apt-get update

# Install docker requirements
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

# Install docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

if [ $experimental ]
then
    # Setup daemon.
    cat > /etc/docker/daemon.json <<EOF
    {
    "experimental": true
    }
EOF

    # Restart docker.
    systemctl daemon-reload
    systemctl restart docker
fi
