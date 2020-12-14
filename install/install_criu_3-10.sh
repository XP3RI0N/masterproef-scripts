#!/bin/bash
set -e

apt update
apt upgrade -y
apt install -y build-essential \
			pkg-config \
			libnet-dev python-yaml libaio-dev \
			libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev python-future

# criu install
curl -O -sSL http://download.openvz.org/criu/criu-3.10.tar.bz2
tar xjf criu-3.10.tar.bz2 
cd criu-3.10
make
cp ./criu/criu /usr/local/bin
cd
