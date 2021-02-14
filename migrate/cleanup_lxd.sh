#!/bin/bash
set -e

lxc stop node1:alpine-www
lxc delete node1:alpine-www
lxc delete alpine-www/snap0

