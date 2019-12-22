#!/bin/bash -e
BASEDIR="$(dirname "$0")"
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh

dpkg -i ${RAMDISK}/*trial*.deb
LOGFILE=/opt/powerai-vision/install_vision.log
echo "INFO: Loading PowerAI Vision Docker images. This will take several minutes..."
time /opt/powerai-vision/bin/load_images.sh -f ${RAMDISK}/powerai-vision-images-*.tar &>${LOGFILE}
echo "INFO: PowerAI Vision Docker images loaded successfully!"
