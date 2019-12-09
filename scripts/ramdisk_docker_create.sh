#!/bin/bash -e
BASEDIR="$(dirname "$0")"
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh

echo "Creating ramdisk for /var/lib/docker..."
sudo mkdir -p $DOCKERMOUNT
sudo chmod 777 $DOCKERMOUNT
sudo mount -t tmpfs -o size=100G ramdisk $DOCKERMOUNT
