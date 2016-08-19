#/bin/sh

set -e

# Configurate Docker daemon
sudo mkdir -p /etc/docker
sudo cp ./daemon.json /etc/docker/daemon.json

# Restart Docker daemon
sudo service docker restart
