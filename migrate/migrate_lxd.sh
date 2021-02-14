#!/bin/bash
set -e

lxc snapshot alpine-www
lxc copy alpine-www/snap0 node1:alpine-www
lxc start node1:alpine-www
