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
# limitations   under the License.


variable "ibmcloud_classic_apikey" {
    description = "Enter your IBM Cloud Classic API Key. To get this key, go to https://cloud.ibm.com/iam/apikeys and generate a new 'Classic Infrastructure API Key'"
}

variable "ibmcloud_classic_username" {
  description = "Enter you IBM Cloud Classic Username."
}

variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key."
}

#################################################
##               End of variables              ##
#################################################

provider "ibm" {
//    region           =  "${var.vpc_region}" #?
    version          = ">= 0.24.4"
    iaas_classic_username = var.ibmcloud_classic_username
    iaas_classic_api_key  = var.ibmcloud_classic_apikey
    ibmcloud_api_key = var.ibmcloud_api_key
}

provider "null" {
    version = "~> 2.1"
}

provider "random" {
    version = "~> 2.2"
}

provider "tls" {
    version = "~> 2.1"
}
