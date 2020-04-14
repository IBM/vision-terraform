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
source ${BASEDIR}/env.sh

# Install aria and get example dataset zip file
echo "Installing aria2..."
apt-get -o Dpkg::Use-Pty=0 update -qq  || echo " RC${?} Got an error on update???"
apt-get -o Dpkg::Use-Pty=0 install -qq aria2

cd $HOME
echo "Fetching example dataset from ${URLPAIVDATASET}"
aria2c -q $URLPAIVDATASET

# Uninstall aria2
echo "Uninstalling aria2"
apt-get -o Dpkg::Use-Pty=0 remove -qq aria2

echo "SUCCESS: Downloaded ${DATASET_NAME} example data set successfully."

git clone https://github.com/IBM/vision-tools.git

powerai_ip=$1
password=$2

# Set env variables to be able to use
export PYTHONPATH=$PYTHONPATH:$HOME/vision-tools/lib
PATH=$PATH:$HOME/vision-tools/cli

# Set VAPI_HOST to floating IP for UI
export VAPI_HOST="${powerai_ip}"

# Try getting token to use CLI
n=0
until [[ $n -ge 5 ]]
do
   VAPI_TOKEN=$(vision users token --user admin --password ${password}) && break
   n=$[$n+1]
   sleep 10
done

if [[ $n -eq 5 ]]; then
    echo "Unable to get token needed to import example data set."
    exit 1
else
    export VAPI_TOKEN
    echo "Token created successfully."
fi

echo "Attempting to import data set...."


# Import Bowls_and_Plates.zip data set
vision datasets import $HOME/${DATASET_NAME}
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "ERROR: Example data set was unable to be imported."
    exit 1
else
    echo "Import of example data set was successful."
fi

