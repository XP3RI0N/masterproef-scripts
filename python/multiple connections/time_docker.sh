#!/bin/bash
set -e

# use time command to time multiple commands time(ls; cd; test.sh)
# https://superuser.com/questions/608591/time-the-execution-time-of-multiple-commands

time(
	# Chekpoint docker container
	docker checkpoint create --checkpoint-dir=/tmp mc-app checkpoint1
)

time (
	# Tar checkpoint and prepare for copy by changing owner
	sudo tar -cf /tmp/checkpoint.tar -C /tmp/ checkpoint1
	sudo chown stijvdnd /tmp/checkpoint.tar

	# Copy checkpoint from node0 to node1
	scp /tmp/checkpoint.tar stijvdnd@10.2.33.42:/tmp/

	# Start container from checkpoint on node1
	ssh 10.2.33.42 << EOF
	cd /tmp
	tar -xf /tmp/checkpoint.tar
EOF
)

ssh 10.2.33.42 << EOF
time (
	docker start --checkpoint-dir=/tmp --checkpoint=checkpoint1 mc-app
)
EOF
