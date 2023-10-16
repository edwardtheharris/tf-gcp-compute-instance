#!/bin/bash

REMOTE=$1

if [[ -f $(command -v) ]]; then
  sudo apt-get -y update
  sudo apt-get -y install netcat
fi

while ! nc -z "${REMOTE}" 22; do
  printf "Waiting for ssh connection. . . \n"
  sleep 0.1 # wait for 1/10 of the second before check again
done
