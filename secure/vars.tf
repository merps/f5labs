variable "cidr" {
  description = "VPC CIDR for Inspection gateway."
}

variable "region" {
  description = "AWS Region to deploy to"
}

variable "azs" {
  description = "AZ's in region wish to deploy to"
  type = list(string)
}

variable "secops-profile" {
  description = "Account name to configure Environment for."
}

variable "customer" {
  description = "Customer Short name AWS deployment is for."
}

variable "ec2_key_name" {
  description = "EC2 KeyPair name"
}

variable "environment" {
  description = "Customer Environment short name for deployment."
}

variable "project" {
  description = "Customer Project short name for deployment."
}
