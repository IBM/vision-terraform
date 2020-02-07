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


#$1 (the first arg) indicates whether we should expect GPUs to be present or not
#  0 or any other value - do NOT expect GPUs to be present
#  1 - expect GPUs to be present.

if [ "$1" -eq "1" ]; then
   echo "INFO: Expecting GPUs to be present";
   exit 0;
fi

echo "WARN: Disabling GPU checks for this installation."
cp /opt/powerai-vision/bin/gpu_setup.sh /opt/powerai-vision/bin/gpu_setup.sh.bak
echo <<ENDGPU > /opt/powerai-vision/bin/gpu_setup.sh
#!/bin/bash -xe

echo "WARN: Skipping GPU Checks"
exit 0

ENDGPU
pushd /
cp /opt/powerai-vision/bin/powerai_vision_start.sh /opt/powerai-vision/bin/powerai_vision_start.sh.bak
patch -p0 <<ENDSTARTUPPATCH
--- /opt/powerai-vision/bin/powerai_vision_start.sh	2019-11-01 14:48:40.280933137 -0500
+++ /opt/powerai-vision/bin/powerai_vision_start.sh	2019-11-01 14:51:22.158084968 -0500
@@ -126,7 +126,7 @@
     if [[ ! -c "/dev/nvidia-uvm" ]]; then
         error "Cannot find nvidia-uvm. This should be loaded by previous step 'gpu_setup.sh'."
         error "More Info: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#runfile-verifications"
-        exit 1
+        warning "No GPUs found. We're still starting up for dev purposes..."
     fi

     # start kubernetes cluster
ENDSTARTUPPATCH

popd
