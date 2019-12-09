#!/bin/bash -e
BASEDIR="$(dirname "$0")"
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh

echo "Creating ramdisk for install media..."
sudo mkdir -p $RAMDISK
sudo chmod 777 $RAMDISK
sudo mount -t tmpfs -o size=20G ramdisk $RAMDISK
