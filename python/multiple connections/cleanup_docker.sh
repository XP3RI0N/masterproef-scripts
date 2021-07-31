#!/bin/bash
set -e

# Cleanup node1
ssh 10.2.33.42 << EOF
cd /tmp
sudo rm -rf checkpoint1 checkpoint.tar

docker stop mc-app
docker container rm mc-app

docker create -p [::]:80:80 --name mc-app mc-image
EOF

# Cleanup node0
cd /tmp
sudo rm -rf checkpoint1 checkpoint.tar
docker container rm mc-app

# Start new container to migrate
docker run -d -p [::]:80:80 --name mc-app mc-image
cd
