#!/bin/bash
set -e

# Cleanup node1
ssh 10.2.33.42 << EOF
cd /tmp
sudo rm -rf checkpoint1 checkpoint.tar

docker stop looper
docker container rm looper

docker create --name looper --security-opt seccomp:unconfined busybox \
	/bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'
EOF

# Cleanup node0
cd /tmp
sudo rm -rf checkpoint1 checkpoint.tar
docker container rm looper

# Start new container to migrate
docker run -d --name looper --security-opt seccomp:unconfined busybox /bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'
cd
