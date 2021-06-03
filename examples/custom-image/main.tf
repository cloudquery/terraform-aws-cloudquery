provider "aws" {
  region = "eu-west-1"
}

#######################################################
# Create custom Docker Image based on the official one
# and push it to ECR registry
#####################################################

data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_ecr_authorization_token" "token" {}

locals {
  ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
  ecr_image   = format("%v/%v:%v", local.ecr_address, aws_ecr_repository.cloudquery.name, "my-latest")
}

resource "aws_ecr_repository" "cloudquery" {
  name = "cloudquery-custom"
}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "docker_registry_image" "cloudquery" {
  name = local.ecr_image

  build {
    context    = "docker"
    dockerfile = "Dockerfile"
  }

}
