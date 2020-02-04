#!/bin/bash -xe
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
