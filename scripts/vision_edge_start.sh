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

echo "INFO: Starting up Maximo Visual Inspection Edge..."

echo "TERRAFORM_TRIAL_LIC_ACCEPTED" >> /opt/ibm/vision-edge/volume/run/var/config/license/VISIONEDGE.ACCEPTANCE.txt
date >> /opt/ibm/vision-edge/volume/run/var/config/license/VISIONEDGE.ACCEPTANCE.txt
date >> /opt/ibm/vision-edge/volume/run/var/initpasswd
sed -i "s/^PULL_REPO.*/PULL_REPO=${REGISTRY_BASE}${REGISTRY_PATH}/" /opt/ibm/vision-edge/volume/run/var/config/vision-edge.properties
/opt/ibm/vision-edge/startedge.sh | tee -a /tmp/scripts/start.log
echo "INFO: Maximo Visual Inspection Edge startup successful!"
