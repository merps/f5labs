#
# Set minimum Terraform version and Terraform Cloud backend
#
terraform {
  required_version = ">= 0.12"
  backend "s3" {
    endpoint = "https://jackdaws.wirelessravens.org:9000/"
    key = "terraform.tfstate"
    region = "main"
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_get_ec2_platforms = true
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

  providers = {
    aws = aws.secops
  }

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

  providers = {
    aws = aws.secops
  }

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

  providers = {
    aws = aws.secops
  }

  prefix         = "${var.project}-${var.environment}"
  azs            = var.azs
  env            = var.environment
  vpcid          = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  random         = random_id.id
  keyname        = var.ec2_key_name
}
