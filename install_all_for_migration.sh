#!/bin/bash
set -e

sh ./enable_nat.sh
sh ./install_docker.sh --experimental
sh ./install_criu.sh
