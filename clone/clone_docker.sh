#!/bin/bash
set -e

# Run container to migrate
# docker run -d --name looper2 --security-opt seccomp:unconfined busybox \
#         /bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'

docker checkpoint create --checkpoint-dir=/tmp looper checkpoint2

docker create --name looper-clone --security-opt seccomp:unconfined busybox \
	/bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'

$ docker start --checkpoint-dir=/tmp --checkpoint=checkpoint2 looper-clone
