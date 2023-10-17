#!/bin/bash

LUSER=$1
LOCAL_PRIVATE_KEY=$2
LOCAL_PUBLIC_KEY=$3

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y $pkg;
done

# Add Docker's official GPG key:
sudo apt-get update
# Install some utilities
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl glances gnupg httpie netdata
# Configure netdata
netdata_config=$(cat <<EOF
# NetData Configuration

# The current full configuration can be retrieved from the running
# server at the URL
#
#   http://localhost:19999/netdata.conf
#
# for example:
#
#   wget -O /etc/netdata/netdata.conf http://localhost:19999/netdata.conf
#

[global]
        run as user = netdata
        web files owner = root
        web files group = root
        # Netdata is not designed to be exposed to potentially hostile
        # networks. See https://github.com/netdata/netdata/issues/164
        bind socket to IP = 0.0.0.0
EOF
)
echo "$netdata_config" | sudo tee /etc/netdata/netdata.conf
# Restart netdata with new config
sudo systemctl restart netdata
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
echo -n "${LOCAL_PUBLIC_KEY}" | base64 -d >> ~/.ssh/authorized_keys
echo -n "${LOCAL_PUBLIC_KEY}" | base64 -d >> ~/.ssh/id_rsa.pub
echo -n "${LOCAL_PRIVATE_KEY}" | base64 -d > ~/.ssh/id_rsa
