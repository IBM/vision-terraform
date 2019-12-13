################################################################
# Module to deploy an VM with specified applications installed
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2019.
#
################################################################

variable "vision_version" {
  description = "V.R.M.F of PowerAI Vision"
  default = "1.1.5.0"
}

variable "vpc_basename" {
  description = "Denotes the name of the VPC that PowerAI Vision will be deployed into. Resources associated with PowerAI Vision will be prepended with this name."
  default = "powerai-vision-trial"
}

variable "expect_gpus" {
  description = "Should the provisioning code expect to find GPU capability? 0 - GPUs disabled; 1 - GPUs enabled and expected to be present"
  default = "1"
}

variable "cos_access_key" {
  description = "AWS Access Key for COS bucket containing install media"
}

variable "cos_secret_access_key" {
  description = "AWS Secret Access Key for COS bucket containing install media"
}

variable "cos_bucket_base" {
  description = "HTTP URL for COS bucket containing install media (e.g. http://region/bucket with no trailing slash)"
}

variable "vision_deb_name" {
  description = "Install debian name (e.g. powerai-vision-1.1.5~trial.deb)"
  default = "powerai-vision_version.deb"
}


variable "vision_tar_name" {
  description = "Install images name (e.g. powerai-vision-1.1.5-images.tar)"
  default = "powerai-vision-images-version.tar"
}

//grand plan:
//cannot ssh from schematics to the host... why???

#################################################
##               End of variables              ##
#################################################


locals {
  boot_image = "r134-7c3562d6-4f7b-45ba-9969-6cf5d5a3fd55" #Ubuntu 18.04 w/GPU support
  vpc_zone = "us-south-1"
  vm_profile = "gp2-24x224x2" #2 GPU instance with 224GB RAM
}

#Create a VPC for the application
resource "ibm_is_vpc" "vpc" {
  name = "${var.vpc_basename}-vpc1"
}

#Create a subnet for the application
resource "ibm_is_subnet" "subnet" {
  name = "${var.vpc_basename}-subnet1"
  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${local.vpc_zone}"
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


  tcp = {
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

  tcp = {
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

  tcp = {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_instance" "vm" {
  name = "${var.vpc_basename}-vm1"
  image = "${local.boot_image}" #Ubuntu 18.04 (w/ GPUs)
  profile = "${local.vm_profile}" #128GBVM - change to a GPU VM

  primary_network_interface = {
    subnet = "${ibm_is_subnet.subnet.id}"
  }

  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${local.vpc_zone}" //make this a variable when there's more than one option...
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
  override_special = "!@#_"
}

#Create a ssh keypair which will be used to provision code onto the system - and also access the VM for debug if needed.
resource "tls_private_key" "vision_keypair" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

data "template_file" "env_template" {
  template = "${file("env.tpl")}"
  vars = {
    cos_access_key        = "${var.cos_access_key}"
    cos_secret_access_key = "${var.cos_secret_access_key}"
    cos_bucket_base       = "${var.cos_bucket_base}"
    vision_deb_name       = "${var.vision_deb_name}"
    vision_tar_name       = "${var.vision_tar_name}"
    vision_version        = "${var.vision_version}"
  }
}


#Provision PowerAI Vision onto the system
resource "null_resource" "provisioners" {

  triggers = {
    vmid = "${ibm_is_instance.vm.id}"
  }

  depends_on = [
    "ibm_is_security_group_rule.sg1-tcp-rule"
  ]


  provisioner "file" {
    source = "./scripts"
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      #host = "${ibm_is_floating_ip.fip1.address}"
      host = "${ibm_is_instance.vm.primary_network_interface.primary_ipv4_address}"
      private_key = "${tls_private_key.vision_keypair.private_key_pem}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.env_template.rendered}"
    destination = "/tmp/scripts/env.sh"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_instance.vm.primary_network_interface.primary_ipv4_address}"
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
      "/tmp/scripts/fetch_vision.sh",
      "/tmp/scripts/install_docker.sh",
      "/tmp/scripts/install_nvidiadocker2.sh",
      "/tmp/scripts/install_vision.sh",
      "/tmp/scripts/ramdisk_tmp_destroy.sh",
      "/tmp/scripts/patch_gpus.sh ${var.expect_gpus}",
      "/tmp/scripts/vision_start.sh",
      "/tmp/scripts/set_vision_pw.sh ${random_password.vision_password.result}",
      "rm -rf /tmp/scripts"
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_instance.vm.primary_network_interface.primary_ipv4_address}"
      private_key = "${tls_private_key.vision_keypair.private_key_pem}"
    }
  }
}

