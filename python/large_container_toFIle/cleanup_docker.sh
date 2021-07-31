#!/bin/bash
set -e

# Cleanup node1
ssh 10.2.33.42 << EOF
cd /tmp
sudo rm -rf checkpoint1 checkpoint.tar

docker stop python-app
docker container rm python-app

docker create --name python-app test-app
EOF

# Cleanup node0
cd /tmp
sudo rm -rf checkpoint1 checkpoint.tar
docker container rm python-app

# Start new container to migrate
docker run -d --name python-app test-app
cd
