#!/bin/bash

usage()
{
    cat << USAGE >&2
Usage:
    wait-for-ssh.sh remote_host private_key public_key remote_user gpg_key_path
      remote_host = Host to which the script should attempt to connnect
      private_key = A base64-encoded valid ssh private key
      public_key = A base64-encoded valid ssh public key matching the private key
      remote_user = The user on the remote host to use for this connection
      gpg_key_path = The path to a GPG key for signing commits
USAGE
  return 1;
}

if [[ -z $3 ]]; then
  usage
else
  # Set the first argument passed to the script to the IP or domain name we
  # will connect to.
  REMOTE=$1
  RUSER=$2
  GPG_KEY_B64=$3

  # Wait for the first argument from the CLI in the form of an IP address or
  # domain name to become open on port 22 from our source IP.
  while ! ./_scripts/wait-for-it.sh "${REMOTE}:22"; do
    printf "Waiting for ssh connection. . . \n"
    sleep 0.1 # wait for 1/10 of the second before check again
  done

  # Copy the docker install script to the remote
  scp -v ./_scripts/install-docker.sh "${RUSER}@${REMOTE}:"
  scp conf/.ssh/config "${RUSER}@${REMOTE}:.ssh/config"
  scp secrets/id_rsa* "${RUSER}@${REMOTE}:.ssh/"
  scp ./_scripts/setup-gpg.sh "${RUSER}@${REMOTE}:"
  scp "${GPG_KEY_PATH}" "${RUSER}@${REMOTE}:"
  scp "${HOME}/.gitconfig" "${RUSER}@${REMOTE}:"
  scp -rv _scripts/completions "${RUSER}@${REMOTE}:completions"

  # Execute the script on the remote machine
  # shellcheck disable=SC2029
  ssh "${RUSER}@${REMOTE}" source "/home/${RUSER}/install-docker.sh ${RUSER}"
  # ssh "${RUSER}@${REMOTE}" sudo cp -rv "/home/${RUSER}/completions/* /usr/share/bash-completion/completions"
  # Execute git setup script on remote
  # shellcheck disable=SC2029
  ssh "${RUSER}@${REMOTE}" source "/home/${RUSER}/setup-gpg.sh ${GPG_KEY_B64}"
  ssh "${RUSER}@${REMOTE}" sudo chmod -v 0600 .ssh/id_rsa
  ssh "${RUSER}@${REMOTE}" minikube start
fi
