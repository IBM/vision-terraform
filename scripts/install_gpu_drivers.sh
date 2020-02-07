#!/bin/bash -e
# Copyright 2020. IBM All Rights Reserved.
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


# Install NVIDIA Driver
modinfo nvidia && which nvidia-smi
has_gpu_driver=$?

if [ $has_gpu_driver -ne 0 ]; then
  # Install Nvidia
  echo "Installing Nvidia drivers."
  deb_name=http://us.download.nvidia.com/tesla/418.116.00/nvidia-driver-local-repo-ubuntu1804-418.116.00_1.0-1_ppc64el.deb
  wget ${deb_name}
  dpkg -i nvidia-driver-local-repo-ubuntu*.deb
  apt-key add /var/nvidia-driver-local*/*.pub
  apt-get -o Dpkg::Use-Pty=0 update -qq
  apt-get -o Dpkg::Use-Pty=0 install -qq nvidia-driver-418

  # Purge the repo
  dpkg -P `dpkg -l | grep nvidia-driver-local-repo-ubuntu | cut -d " " -f 3`
  apt-get clean -y
  rm nvidia-driver-local-repo-*.deb
  systemctl daemon-reload
  systemctl enable nvidia-persistenced
  nvidia-smi
else
  echo "Nvidia drivers installed on machine already. Skipping install of drivers."
fi

systemctl is-active nvidia-persistenced || systemctl enable nvidia-persistenced
