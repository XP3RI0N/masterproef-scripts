#!/bin/bash
set -e

apt-get update
apt-get upgrade

apt-get install software-properties-common

add-apt-repository ppa:ubuntu-lxc/daily
apt-get update

apt-get install lxc
apt-get install lxc-templates
