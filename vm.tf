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


variable "vision_version" {
  description = "V.R.M of IBM Maximo Visual Inspection Edge"
  default = "8.4.0"
}

variable "registry_base" {
  description = "Location of product containers"
  default = "cp.icr.io"
}

variable "registry_path" {
  description = "Location of product containers (can be '' if needed)"
  default = "/cp/visualinspection"
}

variable "registry_user" {
  description = "Entitled Registry Username. For Cloud Pak Certfied Content, hosted in the IBM Entitled Registry, this is 'cp' but can be set to any value needed."
  default = "cp"
}
variable "registry_pass" {
  description = "Entitled Registry Key. Get this from https://myibm.ibm.com/products-services/containerlibrary"
  sensitive = true
}

variable "license_accepted" {
  description = "Do you accept the license for IBM Maximo Visual Inspection Edge?"
}

variable "vpc_basename" {
  description = "Denotes the name of the VPC that IBM Maximo Visual Inspection Edge will be deployed into. Resources will be prepended with this name. Keep this at 25 characters or fewer."
  default = "ibm-mvie-trial"
}

//variable "cos_bucket_base" {
//  description = "HTTP URL for COS bucket containing install media (e.g. http://region/bucket with no trailing slash)"
//  default = "https://vision-cloud-trial.s3.direct.us-east.cloud-object-storage.appdomain.cloud"
//}


//variable "example_dataset_url" {
//  description = "URL of example dataset to automatically import into IBM Maximo Visual Inspection."
//  default = "https://vision-cloud-trial.s3.direct.us-east.cloud-object-storage.appdomain.cloud/Bowls-and-Plates.zip"
//}

variable "boot_image_name" {
  description = "name of the base image for the virtual server (should be an Ubuntu 18.04 base)"
  default = "ibm-ubuntu-18-04-5-minimal-amd64-1"
}


variable "vpc_region" {
  description = "Target region to create this instance of PowerAI Vision"
  default = "us-south"
}

variable "vpc_zone" {
  description = "Target availbility zone to create this instance of Maximo Visual Inspection Edge"
  default = "us-south-1"
}

variable "vm_profile" {
  description = "What VM profile should we create for compute? gx2-8x64x1v100 provides 1 GPU and 64GB of RAM. See https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui#gpu for details."
  default = "gx2-8x64x1v100"
}

#################################################
##               End of variables              ##
#################################################

data "ibm_is_image" "bootimage" {
  name = "${var.boot_image_name}"
}


#Create a VPC for the application
resource "ibm_is_vpc" "vpc" {
  name = "${var.vpc_basename}-vpc1"
}

#Create a subnet for the application
resource "ibm_is_subnet" "subnet" {
  name = "${var.vpc_basename}-subnet1"
  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${var.vpc_zone}"
  ip_version = "ipv4"
  total_ipv4_address_count = 32
}

#Create an SSH key which will be used for provisioning by this template, and for debug purposes
resource "ibm_is_ssh_key" "public_key" {
  name = "${var.vpc_basename}-public-key"
  public_key = "${tls_private_key.vision_keypair.public_key_openssh}"
}

#Create a public floating IP so that the app is available on the Internet
resource "ibm_is_floating_ip" "fip1" {
  name = "${var.vpc_basename}-subnet-fip1"
  target = ibm_is_instance.vm.primary_network_interface.0.id
}

#Enable ssh into the instance for debug
resource "ibm_is_security_group_rule" "sg1-tcp-rule" {
  depends_on = [
    ibm_is_floating_ip.fip1
  ]
  group = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote = "0.0.0.0/0"


  tcp {
    port_min = 22
    port_max = 22
  }
}

#Enable port 443 - main application port
resource "ibm_is_security_group_rule" "sg2-tcp-rule" {
  depends_on = [
    ibm_is_floating_ip.fip1
  ]
  group = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

#Enable port 80 - only use to redirect to port 443
resource "ibm_is_security_group_rule" "sg3-tcp-rule" {
  depends_on = [
    ibm_is_floating_ip.fip1
  ]
  group = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

#Enable port 9001 for deployed model inference
resource "ibm_is_security_group_rule" "sg4-tcp-rule" {
  depends_on = [
    ibm_is_floating_ip.fip1
  ]
  group = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote = "0.0.0.0/0"

  tcp {
    port_min = 9001
    port_max = 9001
  }
}


resource "ibm_is_instance" "vm" {
  name = "${var.vpc_basename}-vm1"
  image = data.ibm_is_image.bootimage.id
  profile = var.vm_profile
  primary_network_interface {
    subnet = "${ibm_is_subnet.subnet.id}"
    security_groups = [ibm_is_vpc.vpc.default_security_group]
  }

  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${var.vpc_zone}" //make this a variable when there's more than one option

  keys = [
    "${ibm_is_ssh_key.public_key.id}"
  ]

  timeouts {
    create = "10m"
    delete = "10m"
  }

}

#Create a login password which will be used for the main PowerAI Vision application
resource "random_password" "vision_password" {
  length = 16
  special = true
  override_special = "!@%"
  min_special = 1
  min_upper = 1
  min_lower = 1
  min_numeric = 1
}

#Create a ssh keypair which will be used to provision code onto the system - and also access the VM for debug if needed.
resource "tls_private_key" "vision_keypair" {
  algorithm = "RSA"
  rsa_bits = "2048"
}


#Provision the app onto the system
resource "null_resource" "provisioners" {

  triggers = {
    vmid = ibm_is_instance.vm.id
  }

  provisioner "file" {
    source = "scripts"
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = ibm_is_floating_ip.fip1.address
      private_key = tls_private_key.vision_keypair.private_key_pem
    }
  }


  provisioner "file" {
    content = <<ENDENVTEMPL
#!/bin/bash -xe
export RAMDISK=/tmp/ramdisk
export DOCKERMOUNT=/var/lib/docker
export REGISTRY_BASE=${var.registry_base}
export REGISTRY_PATH=${var.registry_path}
export REGISTRY_USER=${var.registry_user}
export REGISTRY_PASS=${var.registry_pass}
export VISION_VERSION=${var.vision_version}
ENDENVTEMPL
    destination = "/tmp/scripts/env.sh"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = ibm_is_floating_ip.fip1.address
      private_key = tls_private_key.vision_keypair.private_key_pem
    }
  }

  # initial setup
  provisioner "remote-exec"  {
    inline = [
      "set -e",
      "chmod +x /tmp/scripts*/*",
      #"/tmp/scripts/format_mount_blk.sh",
      "/tmp/scripts/wait_bootfinished.sh",
      "/tmp/scripts/install_gpu_drivers.sh",
      "/tmp/scripts/install_docker.sh",
      "/tmp/scripts/install_nvidiadocker2.sh",
      "/tmp/scripts/install_vision_edge.sh",
      "/tmp/scripts/vision_edge_start.sh"
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = ibm_is_floating_ip.fip1.address
      private_key = tls_private_key.vision_keypair.private_key_pem
    }
  }
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "/tmp/scripts/set_vision_pw.sh ${random_password.vision_password.result}",
      #"/tmp/scripts/import_dataset.sh ${ibm_is_instance.vsi1.ipv4_address} ${random_password.vision_password.result}",
      "rm -rf /tmp/scripts"
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = ibm_is_floating_ip.fip1.address
      private_key = tls_private_key.vision_keypair.private_key_pem
    }
  }
}
