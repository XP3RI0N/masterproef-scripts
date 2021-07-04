#!/bin/bash
set -e
time (
	lxc snapshot alpine-www
)

time (
	lxc copy alpine-www/snap0 node1:alpine-www
)

time (
	lxc start node1:alpine-www
)
