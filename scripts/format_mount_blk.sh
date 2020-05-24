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

#NOTE: This isn't best practice. Instead - use ansible to configure and mount volumes as below. This will not
#function correctly if there's already data on-disk. We also use bind mounts because we want to present to the user
#a set of directories in one file system for their later use, vs separate file systems. This makes managing things  via
#COS or block storage a bit easier for administrators, but creates work inside the VM (see below).

VISION_VOL_LABEL=DATA-vision
echo "INFO: Searching for data volume disk..."
diskid=`lsblk -o NAME,FSTYPE -dsn | awk '$2 == "" {print $1}'`
echo "INFO: Formatting device /dev/${diskid}"
mkfs.xfs -L ${VISION_VOL_LABEL}  "/dev/${diskid}" -n ftype=1 #label for fstab, and ftype=1 per docker manuals for XFS
blkid "/dev/${diskid}"
echo "INFO: Format complete!"
echo "INFO: Setting up /etc/fstab entries..."
export $(blkid "/dev/${diskid}" -o export) #get UUID into a variable...
#Best Practices Q for Review: What / who establishes the order in which the OS mounts these and ensures that a race
#doesn't happen? For example, if the /data volume takes a long time to mount - do the bind mounts hold off?
#Note we use rbind to ensure docker can rbind itself.
echo LABEL=${VISION_VOL_LABEL} /data                   xfs     defaults        0 0 >> /etc/fstab
echo /data/docker /var/lib/docker none defaults,rbind 0 0 >> /etc/fstab
echo /data/vision /opt/ibm/vision none defaults,rbind 0 0 >> /etc/fstab
#create final mount points before mounting them
#note this must be performed in the order written below to ensure that mount
#points and destinations exist
echo "INFO: Final /etc/fstab contents:"
cat /etc/fstab
echo "INFO: Setting up mount points and final targets..."
mkdir /data
mkdir -p /var/lib/docker
mkdir -p /opt/ibm/vision
#mount the data file system ONLY
echo "INFO: Mounting data volume..."
mount /data
echo "INFO: Creating intermediate bind mounts targets..."
#create bind mount destinations on the data volume
mkdir /data/docker #create bind mount point on data volume
mkdir /data/vision #create bind mount point on data volume
#complete mounts using systemd to resolve ordering
mount -a
echo "SUCCESS: All mount points created and mounted successfully!"
