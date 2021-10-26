#!/bin/bash -e
# Copyright 2019. IBM All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get -o Dpkg::Use-Pty=0 update -qq
sudo apt-get -o Dpkg::Use-Pty=0 install -qq nvidia-docker2 jq
# back up the docker daemon configuration
cp /etc/docker/daemon.json /etc/docker/daemon.json.orig
#set the default docker runtime to the nvidia runtime is installed above
cat /etc/docker/daemon.json.orig| jq '. + {"default-runtime": "nvidia"}' > /etc/docker/daemon.json
#restart docker to pick up the changes, and show that the runtime is now the nvidia runtime
systemctl restart docker
docker info
echo "SUCCESS: nvidia-docker2 started, and default docker runtime set to nvidia!"
