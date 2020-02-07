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

echo "Setting PowerAI Vision password..."
echo "Waiting for authorization services to start up..."

RETRYCOUNT=0
RETRYDELAY=120
MAXRETRIES=5 #300 seconds, or 5 minutes
until /opt/powerai-vision/bin/kubectl.sh wait --for=condition=available deployment/powerai-vision-keycloak --timeout=${RETRYDELAY}s; do
  RETRYCOUNT=$((RETRYCOUNT + 1))
  if [ "${RETRYCOUNT}" -eq "${MAXRETRIES}" ]; then
    echo "ERROR: Keycloak deployment failed to become available within ${MAXRETRIES} attempts of checking."
    exit 1
  fi
done


/opt/powerai-vision/bin/kubectl.sh run --rm -i --restart=Never usermgt --image=${USERMGTIMAGE} -- modify --user admin --password $1
echo "PowerAI Vision password set!"
