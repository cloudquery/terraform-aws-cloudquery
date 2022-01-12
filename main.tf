locals {
  # VPC - existing or new?
  vpc_id                      = var.vpc_id == "" ? module.vpc.vpc_id : var.vpc_id
  public_subnet_ids           = coalescelist(module.vpc.public_subnets, var.public_subnet_ids, [""])
  private_subnet_ids          = coalescelist(module.vpc.private_subnets, var.private_subnet_ids, [""])
  private_subnets_cidr_blocks = coalescelist(module.vpc.private_subnets_cidr_blocks, var.private_subnets_cidr_blocks, [""])

  cq_dsn = "user=${module.rds.rds_cluster_master_username} password=${module.rds.rds_cluster_master_password} host=${module.rds.rds_cluster_endpoint} port=${module.rds.rds_cluster_port} dbname=${module.rds.rds_cluster_database_name}"

  tags = merge(
    {
      CloudQuery = var.name
    },
    var.tags,
  )
}

###################
# VPC
###################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  create_vpc = var.vpc_id == ""

  name = var.name

  cidr            = var.cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

###################
# Security groups
###################

module "lambda_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.name}-lambda"
  vpc_id      = local.vpc_id
  description = "Allow outbound connections to the world"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]

  tags = merge(local.tags, var.lambda_security_group_tags)
}

######
# RDS
######

module "rds" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 5.0"

  name = "${var.name}-rds"

  # Available versions per region are listed here:
  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraFeaturesRegionsDBEngines.grids.html#Concepts.Aurora_Fea_Regions_DB-eng.Feature.Serverless
  engine         = "aurora-postgresql"
  engine_version = var.aurora_engine_version
  engine_mode    = "serverless"

  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids

  create_security_group = true
  allowed_cidr_blocks   = local.private_subnets_cidr_blocks

  database_name = "cloudquery"
  username      = "cloudquery"

  replica_scale_enabled = false
  replica_count         = 0
  storage_encrypted     = true
  skip_final_snapshot   = true
  apply_immediately     = true
  enable_http_endpoint  = true

  scaling_configuration = {
    auto_pause               = var.aurora_auto_pause
    min_capacity             = var.aurora_min_capacity
    max_capacity             = var.aurora_max_capacity
    seconds_until_auto_pause = var.aurora_seconds_until_auto_pause
    timeout_action           = "ForceApplyCapacityChange"
  }
}

#########
# Lambda
#########

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  create_package = false

  package_type = "Image"
  image_uri    = var.use_existing_ecr_image ? var.cloudquery_image : docker_registry_image.cloudquery[0].name

  function_name = var.name
  description   = "Lambda function which runs CloudQuery CLI"
  publish       = true
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout

  vpc_subnet_ids                 = local.private_subnet_ids
  vpc_security_group_ids         = [module.lambda_sg.security_group_id]
  attach_network_policy          = true
  reserved_concurrent_executions = 1
  environment_variables = {
    CQ_DRIVER     = "postgresql"
    CQ_DSN        = local.cq_dsn
    CQ_PLUGIN_DIR = "/tmp"
  }

  attach_tracing_policy = true
  tracing_mode          = "Active"

  attach_policies    = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]

  # Bug in Terraform AWS provider - https://github.com/hashicorp/terraform-provider-aws/pull/17610
  # Disabling lambda permission resource until it is fixed.
  create_current_version_allowed_triggers = false

  allowed_triggers = {
    AllowExecutionFromEventBridge = {
      service    = "events"
      source_arn = module.eventbridge.eventbridge_rule_arns["cloudquery-fetch"]
    }
  }
}

################################
# EventBridge Rules and Targets
################################

module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 1.0"

  create_bus = false

  rules = {
    cloudquery-fetch = {
      description         = "Run cloudquery fetch"
      schedule_expression = var.cloudquery_fetch_schedule
    }
  }

  targets = {
    cloudquery-fetch = [
      {
        name = "fetch-using-config-file"
        arn  = module.lambda.lambda_function_arn
        input = jsonencode({
          "taskName" : "fetch",
          "hcl" : file("${path.module}/tasks/config.hcl")
        })
      }
    ]
  }

  tags = local.tags
}

#################
# ECR Repository
#################

data "aws_ecr_repository" "cloudquery" {
  count = var.create_ecr_repository && !var.use_existing_ecr_image ? 0 : 1

  name = var.ecr_repository_name
}

resource "aws_ecr_repository" "cloudquery" {
  count = var.create_ecr_repository && !var.use_existing_ecr_image ? 1 : 0

  name = var.ecr_repository_name
  tags = var.tags
}

#####################################################
# Create Docker Image from the official source image
# and push it to ECR registry
#####################################################

data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_ecr_authorization_token" "token" {}

locals {
  source_image = coalesce(var.cloudquery_image, format("ghcr.io/cloudquery/cloudquery:%v", var.cloudquery_version))

  ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
  ecr_image   = format("%v/%v:%v", local.ecr_address, element(concat(data.aws_ecr_repository.cloudquery.*.id, aws_ecr_repository.cloudquery.*.id, [""]), 0), var.cloudquery_version)
}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "local_file" "dockerfile" {
  count = var.use_existing_ecr_image ? 0 : 1

  filename = "docker/Dockerfile"
  content  = "FROM ${local.source_image}"
}

resource "docker_registry_image" "cloudquery" {
  count = var.use_existing_ecr_image ? 0 : 1

  name = local.ecr_image

  build {
    context = "docker"
  }

  depends_on = [local_file.dockerfile]
}
