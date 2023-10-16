#!/bin/bash

REMOTE=$1

while ! ./_scripts/wait-for-it/wait-for-it.sh "${REMOTE}:22" -z "${REMOTE}" 22; do
  printf "Waiting for ssh connection. . . \n"
  sleep 0.1 # wait for 1/10 of the second before check again
done
