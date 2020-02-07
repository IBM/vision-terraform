# Copyright 2019, 2020. IBM All Rights Reserved.
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


output "PowerAI Vision UI" {
    value = "https://${ibm_is_floating_ip.fip1.address}/powerai-vision"
}

output "PowerAI Vision 'admin' password" {
  value = "${random_password.vision_password.result}"
}

output "Instance Private Key (for debug purposes)" {
  value = "\n${tls_private_key.vision_keypair.private_key_pem}"
}
