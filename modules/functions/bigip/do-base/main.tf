locals {
  address = var.bigip_mgmt_public_ip
}
provider "bigip" {
  address = local.address
  username = var.bigip_mgmt_admin
  password = var.bigip_mgmt_passwd
}

resource "bigip_do"  "do-this" {
  do_json = file("${path.module}/do-declaration.json")
  tenant_name = "thang"
}
