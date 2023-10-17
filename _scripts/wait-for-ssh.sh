#!/bin/bash


usage()
{
    cat << USAGE >&2
Usage:
    wait-for-ssh.sh remote_host private_key public_key remote_user
      remote_host = Host to which the script should attempt to connnect
      private_key = A base64-encoded valid ssh private key
      public_key = A base64-encoded valid ssh public key matching the private key
      remote_user = The user on the remote host to use for this connection
USAGE
  return 1;
}

if [[ -z $4 ]]; then
  usage
else
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
fi
