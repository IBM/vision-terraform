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

BASEDIR="$(dirname "$0")"
# shellcheck disable=SC2034
# shellcheck disable=SC2034
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh

#PATCHLIST
PATCH1FILE=patch-v1200-service.tar #PATCH 1 - V1200 - vision-service - resolved in tracker/14394

declare -a PATCHLIST=(
    "${COS_BUCKET_BASE}/${PATCH1FILE}"
    )
echo "Installing aria2..."
apt-get -o Dpkg::Use-Pty=0 update -qq  || echo " RC${?} Got an error on update???"
apt-get -o Dpkg::Use-Pty=0 install -qq aria2

#Fetch the patches
echo "Downloading to ${RAMDISK}..."
pushd $RAMDISK
echo "Fetching patches..."
for patchfile in "${PATCHLIST[@]}"; do
    echo "Fetching patch ${patchfile} from COS..."
    aria2c -q -s160 -x16 $patchfile
done

#Apply patches
#PATCH 1
docker tag vision-service:1.2.0.0 vision-service:1.2.0.0-backup
docker load -i $PATCH1FILE


echo "Uninstalling aria2"
apt-get -o Dpkg::Use-Pty=0 remove -qq aria2
echo "SUCCESS: Patches applied successfully!"
popd
