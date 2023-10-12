#!/bin/bash

LUSER=$1
LOCAL_PRIVATE_KEY=$2

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y $pkg;
done

# Add Docker's official GPG key:
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources
# shellcheck disable=SC2046,SC2027,SC1091
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get auto-remove -y
sudo usermod -a -G docker "${LUSER}"
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo update-alternatives --set editor /usr/bin/vim.basic
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''
ssh-keyscan gitlab.bouncex.net >> ~/.ssh/known_hosts
echo "${SSH_PUBLIC_KEY}" >> ~/.ssh/authorized_keys
echo -n "${LOCAL_PRIVATE_KEY}" | base64 -d > ~/.ssh/id_rsa

