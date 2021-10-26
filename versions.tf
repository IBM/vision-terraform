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

variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key."
}

#################################################
##               End of variables              ##
#################################################

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.33.1"
    }
    null = {
      version = ">= 3.1"
    }

    random = {
      version = ">= 3.1"
    }
    tls = {
      version = ">= 3.1"
    }
  }
}


provider "ibm" {
//    region           =  "${var.vpc_region}" #?
    ibmcloud_api_key = var.ibmcloud_api_key
}

provider "null" {
}

provider "random" {
}

provider "tls" {
}
