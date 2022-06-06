provider "aws" {
  region = "us-east-1"
}

locals {
  cidr = "10.10.0.0/16"
}

data "aws_availability_zones" "available" {}

##############################################################
# VPC
##############################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  create_vpc = true

  name = "cloudquery-vpc"

  cidr             = local.cidr
  azs              = [for v in slice(data.aws_availability_zones.available.names, 0, 2) : v]
  public_subnets   = [for k, v in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(local.cidr, 8, k)]
  private_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(local.cidr, 8, k + 10)]
  database_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(local.cidr, 8, k + 20)]

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  create_egress_only_igw = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
}
##############################################################
# CloudQuery
##############################################################

module "cloudquery" {
  source = "../../"

  # Name to use on all resources created (VPC, RDS, etc)
  name = "cloudquery-complete-example"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnets
  database_subnet_group = module.vpc.database_subnet_group

  config_file = "config.hcl"
}
