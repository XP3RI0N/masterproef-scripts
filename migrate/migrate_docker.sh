#!/bin/bash
set -e

# Chekpoint docker container
docker checkpoint create --checkpoint-dir=/tmp looper checkpoint1

# Tar checkpoint and prepare for copy by changing owner
sudo tar -cf /tmp/checkpoint.tar -C /tmp/ checkpoint1
sudo chown stijvdnd /tmp/checkpoint.tar

# Copy checkpoint from node0 to node1
scp /tmp/checkpoint.tar stijvdnd@10.2.33.42:/tmp/

# Start container from checkpoint on node1
ssh 10.2.33.42 << EOF
cd /tmp
tar -xf /tmp/checkpoint.tar

docker create --name looper --security-opt seccomp:unconfined busybox \
	/bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'
docker start --checkpoint-dir=/tmp --checkpoint=checkpoint1 looper
EOF

