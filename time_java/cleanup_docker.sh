#!/bin/bash
set -e

# Cleanup node1
ssh 10.2.33.42 << EOF
cd /tmp
sudo rm -rf checkpoint1 checkpoint.tar

docker stop java-app
docker container rm java-app

docker create --name java-app my-java-app
EOF

# Cleanup node0
cd /tmp
sudo rm -rf checkpoint1 checkpoint.tar
docker container rm java-app

# Start new container to migrate
docker run -d --name java-app my-java-app
cd
