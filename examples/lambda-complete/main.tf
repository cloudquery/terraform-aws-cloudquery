provider "aws" {
  region = "eu-west-1"
}

locals {
  cidr = "10.20.0.0/16"
}

data "aws_availability_zones" "available" {}

##############################################################
# CloudQuery
##############################################################

module "cloudquery" {
  source = "../../modules/eks"

  # Name to use on all resources created (VPC, RDS, etc)
  name = "cloudquery"

  #####################
  # CloudQuery Service
  #####################

  # CloudQuery version. If not specified, the latest will be used.
  #  cloudquery_version = "0.13.4"

  ###################################
  # Infrastructure (to be created)
  ###################################

  # The CIDR block for the VPC.
  # type: string
  cidr = local.cidr

  # A list of availability zones names or ids in the region
  # type: list(string)
  azs = [for v in data.aws_availability_zones.available.names : v]

  # A list of public subnets
  # type: list(string)
  public_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.cidr, 8, k)]

  # A list of private subnets
  # type: list(string)
  private_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.cidr, 8, k + 10)]

  ##############################################
  # Infrastructure (use existing VPC resources)
  ##############################################

  #  vpc_id                      = "vpc-9651acf1"
  #  public_subnet_ids           = ["subnet-6fe3d837", "subnet-9211eef5", "subnet-e29d66ab"]
  #  private_subnet_ids          = ["subnet-6fe3d837", "subnet-9211eef5", "subnet-e29d66ab"]
  #  private_subnets_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]

}
