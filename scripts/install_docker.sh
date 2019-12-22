#!/bin/bash -e

apt-get -qq -o Dpkg::Use-Pty=0 update
sudo apt-get -qq -o Dpkg::Use-Pty=0 -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
arch=`dpkg --print-architecture`
add-apt-repository "deb [arch=${arch}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get -qq -o Dpkg::Use-Pty=0 update
apt-get -qq -o Dpkg::Use-Pty=0 -y install docker-ce=18.06.1~ce~3-0~ubuntu

echo "SUCCESS: Docker is now installed!"
