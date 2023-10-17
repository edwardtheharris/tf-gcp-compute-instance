#!/bin/bash

# Set the first argument passed to the script to the IP or domain name we
# will connect to.
REMOTE=$1
PRIVATE_KEY=$2
PUBLIC_KEY=$3
RUSER=$4

# Wait for the first argument from the CLI in the form of an IP address or
# domain name to become open on port 22 from our source IP.
while ! ./_scripts/wait-for-it.sh "${REMOTE}:22"; do
  printf "Waiting for ssh connection. . . \n"
  sleep 0.1 # wait for 1/10 of the second before check again
done

# Copy the docker install script to the remote
scp ./_scripts/install-docker.sh "${RUSER}@${REMOTE}:"

# Execute the script on the remote machine
# shellcheck disable=SC2029
ssh "${RUSER}@${REMOTE}" source "/home/${RUSER}/install-docker.sh ${RUSER} ${PRIVATE_KEY} ${PUBLIC_KEY}"
