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

BASEDIR="$(dirname "$0")"
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh

dpkg -i ${RAMDISK}/*trial*.deb
LOGFILE=/opt/powerai-vision/install_vision.log
echo "INFO: Loading PowerAI Vision Docker images. This will take several minutes..."
time /opt/powerai-vision/bin/load_images.sh -f ${RAMDISK}/powerai-vision-images-*.tar &>${LOGFILE}
echo "INFO: PowerAI Vision Docker images loaded successfully!"
