output "PowerAI Vision UI" {
    value = "https://${ibm_is_floating_ip.fip1.address}/powerai-vision"
}

output "PowerAI Vision 'admin' password" {
  value = "${random_password.vision_password.result}"
}

output "Instance Private Key (for debug purposes)" {
  value = "\n${tls_private_key.vision_keypair.private_key_pem}"
}
