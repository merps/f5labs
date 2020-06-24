#
# Set minimum Terraform version and Terraform Cloud backend
#
terraform {
  required_version = ">= 0.12"
  backend "s3" {
    endpoint = "https://jackdaws.wirelessravens.org:9000/"
    key = "terraform.tfstate"
    region = "main"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
  }
}
/*
# Create a random id
*/
resource "random_id" "id" {
  byte_length = 2
}
/*
# Create VPC as per requirements
*/
module "vpc" {
  source = "../modules/services/network"

  prefix = "${var.project}-${var.environment}"
  cidr   = var.cidr
  azs    = var.azs
  env    = var.environment
  random = random_id.id

}
/*
# Create BIG-IP host as per requirements
*/
module "bigip" {
  source = "../modules/functions/bigip"

  prefix           = "${var.project}-${var.environment}"
  cidr             = var.cidr
  azs              = var.azs
  env              = var.environment
  vpcid            = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  database_subnets = module.vpc.database_subnets
  random           = random_id.id
  keyname          = var.ec2_key_name
}
/*
# Create Jump host as per requirements
*/
module "jumphost" {
  source = "../modules/functions/jumphost"

  prefix         = "${var.project}-${var.environment}"
  azs            = var.azs
  env            = var.environment
  vpcid          = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  random         = random_id.id
  keyname        = var.ec2_key_name
}

# TODO break time but must extract string var and pass
/*
module "bigip_do_base" {
  source = "../modules/functions/do-base"

  bigip_mgmt_public_ip = module.bigip.mgmt_public_dns[0]
  bigip_mgmt_admin = "admin"
  bigip_mgmt_passwd = module.bigip.bigip_password

}
*/
# TODO need to update the json template so this common is out at the moment
/*
module "bigip_as3_common" {
  source = "./as3-common"

  bigip_mgmt_public_ip = module.bigip.mgmt_addresses[0]
  bigip_mgmt_admin = "admin"
  bigip_mgmt_passwd = aws_secretsmanager_secret_version.bigip-pwd.secret_string

}
*/