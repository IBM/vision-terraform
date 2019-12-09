#!/bin/bash -e
BASEDIR="$(dirname "$0")"
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh

dpkg -i ${RAMDISK}/*trial*.deb
time /opt/powerai-vision/bin/load_images.sh -f ${RAMDISK}/powerai-vision-images-*.tar
