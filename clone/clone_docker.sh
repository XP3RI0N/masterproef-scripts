#!/bin/bash
set -e

# Run container to migrate
# docker run -d --name looper --security-opt seccomp:unconfined busybox /bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'

docker checkpoint create --checkpoint-dir=/tmp looper checkpoint1

docker create --name looper-clone --security-opt seccomp:unconfined busybox \
	/bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'

$ docker start --checkpoint-dir=/tmp --checkpoint=checkpoint1 looper-clone
