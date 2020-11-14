#!/bin/bash
set -e

# Install CRIU compile dependencies

apt update
apt install -y \
	gcc \
	build-essential \
	bsdmainutils \
	python \
	git-core \
	asciidoc \
	make \
	htop \
	git \
	curl \
	supervisor \
	cgroup-lite \
	libapparmor-dev \
	libseccomp-dev \
	libprotobuf-dev \
	libprotobuf-c-dev \
	protobuf-compiler \
	protobuf-c-compiler \
	python-protobuf \
	libnl-3-dev \
	libcap-dev \
	libaio-dev \
	apparmor \
	libnet1-dev

# Clone and make CRIU
git clone  https://github.com/xemul/criu.git criu
cd criu
make clean
make
make install

# Check instalation: desired output = "looks good"
criu check
