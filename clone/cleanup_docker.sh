#!/bin/bash
set -e

docker stop $(docker ps -q)
docker container rm $(docker ps -aq)
sudo rm -rf /tmp/checkpoint1

docker run -d --name looper --security-opt seccomp:unconfined busybox /bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'

