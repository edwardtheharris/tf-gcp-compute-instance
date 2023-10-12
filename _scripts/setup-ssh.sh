#!/bin/bash

LOCAL_PRIVATE_KEY=$1
LOCAL_PUBLIC_KEY=$2
LUSER=$3

sudo -u "${LUSER}" ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''
ssh-keyscan gitlab.bouncex.net | sudo -u "${LUSER}" tee -a ~/.ssh/known_hosts
echo "${SSH_PUBLIC_KEY}" | sudo -u "${LUSER}" tee -a ~/.ssh/authorized_keys
echo "${LOCAL_PRIVATE_KEY}" | sudo -u "${LUSER}" tee ~/.ssh/id_ed25519
echo "${LOCAL_PUBLIC_KEY}" | sudo -u "${LUSER}" tee ~/.ssh/id_ed25519.pub
