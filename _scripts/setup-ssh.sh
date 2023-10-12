#!/bin/bash

ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''
ssh-keyscan gitlab.bouncex.net >> ~/.ssh/known_hosts
echo "${SSH_PUBLIC_KEY}" >> ~/.ssh/authorized_keys
echo "${LOCAL_PRIVATE_KEY}" > ~/.ssh/id_ed25519
echo "${LOCAL_PUBLIC_KEY}" > ~/.ssh/id_ed25519.pub
