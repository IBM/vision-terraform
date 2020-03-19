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
  description = "V.R.M.F of IBM Visual Insights"
  default = "1.2.0.0"
}

variable "vpc_basename" {
  description = "Denotes the name of the VPC that IBM Visual Insights will be deployed into. Resources associated with IBM Visual Insights will be prepended with this name."
  default = "ibm-visual-insights-trial"
}

variable "cos_bucket_base" {
  description = "HTTP URL for COS bucket containing install media (e.g. http://region/bucket with no trailing slash)"
  default = "https://vision-cloud-trial.s3.direct.us-east.cloud-object-storage.appdomain.cloud"
}

variable "vision_deb_name" {
  description = "Install debian name (e.g. visual-insights_1.x.y.deb )"
  default = "visual-insights_1.2.0.0-508.bfb5f12~trial_ppc64el.deb"
}

variable "vision_tar_name" {
  description = "Install images name (e.g. visual-insights-images-1.x.y.0.tar)"
  default = "visual-insights-images-1.2.0.0.tar"
}

variable "boot_image_name" {
  description = "name of the base image for the virtual server (should be an Ubuntu 18.04 base)"
  default = "ibm-ubuntu-18-04-3-minimal-ppc64le-2" #Ubuntu 18.04
}

variable "vpc_region" {
  description = "Target region to create this instance of IBM Visual Insights"
  default = "us-south"
}

variable "vpc_zone" {
  description = "Target availbility zone to create this instance of IBM Visual Insights"
  default = "us-south-1"
}

variable "vm_profile" {
  description = "What resources or VM profile should we create for compute? gp2-24x224x2 provides 2 GPUs and 224GB RAM"
  default = "gp2-24x224x2"
}

#################################################
##               End of variables              ##
#################################################

data ibm_is_image "bootimage" {
    name =  "${var.boot_image_name}"
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
  target = "${ibm_is_instance.vm.primary_network_interface.0.id}"
}

#Enable ssh into the instance for debug
resource "ibm_is_security_group_rule" "sg1-tcp-rule" {
  depends_on = [
    "ibm_is_floating_ip.fip1"
  ]
  group = "${ibm_is_vpc.vpc.default_security_group}"
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
    "ibm_is_floating_ip.fip1"
  ]
  group = "${ibm_is_vpc.vpc.default_security_group}"
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
    "ibm_is_floating_ip.fip1"
  ]
  group = "${ibm_is_vpc.vpc.default_security_group}"
  direction = "inbound"
  remote = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_instance" "vm" {
  name = "${var.vpc_basename}-vm1"
  image = "${data.ibm_is_image.bootimage.id}"
  profile = "${var.vm_profile}"

  primary_network_interface {
    subnet = "${ibm_is_subnet.subnet.id}"
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

#Create a login password which will be used for the main IBM Visual Insights application
resource "random_password" "vision_password" {
  length = 16
  special = true
  override_special = "!@_"
}

#Create a ssh keypair which will be used to provision code onto the system - and also access the VM for debug if needed.
resource "tls_private_key" "vision_keypair" {
  algorithm = "RSA"
  rsa_bits = "2048"
}


#Provision the app onto the system
resource "null_resource" "provisioners" {

  triggers = {
    vmid = "${ibm_is_instance.vm.id}"
  }

  depends_on = [
    "ibm_is_security_group_rule.sg1-tcp-rule"
  ]

  provisioner "file" {
    source = "scripts"
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip1.address}"
      private_key = "${tls_private_key.vision_keypair.private_key_pem}"
    }
  }


  provisioner "file" {
    content = <<ENDENVTEMPL
#!/bin/bash -xe
export RAMDISK=/tmp/ramdisk
export DOCKERMOUNT=/var/lib/docker
export USERMGTIMAGE=vision-usermgt:${var.vision_version}
export COS_BUCKET_BASE=${var.cos_bucket_base}
export URLPAIVIMAGES="$${COS_BUCKET_BASE}/${var.vision_tar_name}"
export URLPAIVDEB="$${COS_BUCKET_BASE}/${var.vision_deb_name}"
ENDENVTEMPL
    destination = "/tmp/scripts/env.sh"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip1.address}"
      private_key = "${tls_private_key.vision_keypair.private_key_pem}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/scripts*/*",
      "/tmp/scripts/ramdisk_tmp_create.sh",
      "/tmp/scripts/ramdisk_docker_create.sh",
      "/tmp/scripts/wait_bootfinished.sh",
      "/tmp/scripts/install_gpu_drivers.sh",
      "/tmp/scripts/fetch_vision.sh",
      "/tmp/scripts/install_docker.sh",
      "/tmp/scripts/install_nvidiadocker2.sh",
      "/tmp/scripts/install_vision.sh",
      "/tmp/scripts/ramdisk_tmp_destroy.sh",
      "/tmp/scripts/vision_start.sh",
      "/tmp/scripts/set_vision_pw.sh ${random_password.vision_password.result}",
      "rm -rf /tmp/scripts"
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip1.address}"
      private_key = "${tls_private_key.vision_keypair.private_key_pem}"
    }
  }
}
