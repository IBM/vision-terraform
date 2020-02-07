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

#Patch the self-signed certs to avoid problems with MacOS Catalina in installs after July 2019.
EXPIRATION=800
echo "WARN: Patching self-signed certificate creation to create a certificate that expires in $EXPIRATION days."
pushd /
cp /opt/powerai-vision/bin/k8s_start.sh /opt/powerai-vision/bin/k8s_start.sh.bak
#Note we use HEREDOC format, with 'quotes' around the end text. This will prevent the entire text block from being expanded per the bash manual
patch -p0 <<'ENDCERTPATCH'
--- /opt/powerai-vision/bin/k8s_start.sh	2019-11-04 21:59:50.000000000 -0600
+++ /opt/powerai-vision/bin/k8s_start.sh	2019-12-22 00:01:00.445014029 -0600
@@ -74,14 +74,14 @@
     ORIG_UMASK=$(umask)
     umask 0077
     openssl genrsa -out ca.key 2048 &>> $LOG_DIR/start_k8s.log
-    openssl req -x509 -new -nodes -key ca.key -subj "/O=IBM PowerAI Vision/CN=${MASTER}" -days 10000 -out ca.crt &>> $LOG_DIR/start_k8s.log
+    openssl req -x509 -new -nodes -key ca.key -subj "/O=IBM PowerAI Vision/CN=${MASTER}" -days 800 -out ca.crt &>> $LOG_DIR/start_k8s.log
     openssl genrsa -out server.key 2048 &>> $LOG_DIR/start_k8s.log
     # Create the csr.conf used to generate the cert - we need the MASTER and first IP in the range
     K8S_SERVICE_IP=${K8S_SERVICE_IP_RANGE%0/*}1
     sed "s/%MASTER%/${MASTER}/g; s/%HOSTNAME%/`hostname`/g; s/%K8S_SERVICE_IP%/${K8S_SERVICE_IP}/g" $K8S_TEMPLATE_DIR/csr.conf > $CONFIG_DIR/csr.conf

     openssl req -new -key server.key -out server.csr -config csr.conf &>> $LOG_DIR/start_k8s.log
-    openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 10000 -extensions v3_ext -extfile csr.conf &>> $LOG_DIR/start_k8s.log
+    openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 800 -extensions v3_ext -extfile csr.conf &>> $LOG_DIR/start_k8s.log
     umask $ORIG_UMASK
     popd &>/dev/null
     # We generated new certs - so let's make absolutely sure that the etcd directory
ENDCERTPATCH
popd
