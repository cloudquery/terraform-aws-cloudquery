provider "aws" {
  region = "us-east-1"
}

##############################################################
# CloudQuery
##############################################################

module "cloudquery" {
  source = "../../"

  # Name to use on all resources created (VPC, RDS, etc)
  name = "cloudquery-complete-example"

  config_file = "${path.cwd}/config.hcl"
  # install_helm_chart = true
}
