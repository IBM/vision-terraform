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

INSTALL_ROOT="/opt/ibm/vision-edge"

function wait_for_it {
        echo "Waiting for DB to be ready"
        PGREADY=false
        DBREADY=false
        for _ in {1..60}; do
                if [ -f "${INSTALL_ROOT}/volume/run/var/initdb" ]; then
                        DBREADY=true
                        break
                else
                        echo -n "."
                        sleep 1
                fi
        done
        if $DBREADY; then
                while ! $PGREADY; do
                        docker exec vision-edge-controller pg_isready 
                        if [[ $? -ne 0 ]]; then
                                sleep 2
                        else
                                PGREADY=true
                        fi
                done
        else
                return 1
        fi

        return 0
}

echo "Setting IBM Maximo Visual Inspection Edge password..."

wait_for_it
if [[ $? -ne 0 ]]; then
        echo "Database is taking too long to start... giving up"
        exit 1
fi

#read the default password into a variable we can pass to the container... note that
#this needs to account for special characters which may appear in the password.
docker exec -it vision-edge-controller /opt/ibm/vision-edge/bin/cli setpasswd -u masadmin -o "VisionP@ssw0rd" -n "${1}"
echo "IBM Maximo Visual Inspection password set!"
