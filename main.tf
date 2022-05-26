locals {
  # VPC - existing or new?
  vpc_id = var.vpc_id == null ? module.vpc.vpc_id : var.vpc_id
  # if vpc_id is null, use public_subnet from vpc module Otherwise ask the user for public_subnet_ids in addition to vpc_id
  public_subnet_ids = coalescelist(module.vpc.public_subnets, var.public_subnet_ids, [""])
  # if vpc_id is null, use database_subnet_group from vpc module Otherwise ask the user for database_subnet_group in addition to vpc_id
  database_subnet_group = var.database_subnet_group == "" ? module.vpc.database_subnet_group : var.database_subnet_group
  # Default CIDR for the VPC to be created if vpc_id is not provided
  # cidr = "10.10.0.0/16"

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

data "aws_availability_zones" "available" {}

data "aws_vpc" "cq_vpc" {
  id = local.vpc_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  create_vpc = var.vpc_id == null

  name = var.name

  cidr             = "10.10.0.0/16"
  azs              = [for v in slice(data.aws_availability_zones.available.names, 0, 2) : v]
  public_subnets   = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets  = ["10.10.11.0/24", "10.10.12.0/24"]
  database_subnets = ["10.10.21.0/24", "10.10.22.0/24"]

  # cidr = local.cidr
  # If we are creating vpc use all the available zones. If a user wants to control the vpc
  # he needs to create the VPC outside the module and configure it.
  # azs = [for v in slice(data.aws_availability_zones.available.names, 0, 2) : v]
  # public_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(local.cidr, 8, k)]
  # private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(local.cidr, 8, k + 10)]
  # database_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(local.cidr, 8, k + 20)]

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  create_egress_only_igw = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  tags = local.tags
}

###################
# Security groups
###################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = var.name
  description = "CloudQuery RDS Security Group"
  vpc_id      = local.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.aws_vpc.cq_vpc.cidr_block
    },
  ]

  tags = local.tags
}

######
# EKS
######

module "cluster_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.20"

  role_name = "${var.name}-eksa-irsa"

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      # this expects namespace:service_account_name
      namespace_service_accounts = ["cloudquery:${var.name}"]
    }
  }

  role_policy_arns = var.role_policy_arns
  tags             = local.tags
  depends_on = [
    module.iam_policy
  ]
}


resource "aws_iam_role_policy_attachment" "irsa" {
  role       = module.cluster_irsa.iam_role_name
  policy_arn = module.iam_policy.arn
}


module "cluster_irsa_cloudwatch" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.20"

  role_name = "${var.name}-eksa-irsa-cloudwatch"

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      # this expects namespace:service_account_name
      namespace_service_accounts = ["amazon-cloudwatch:fluent-bit"]
    }
  }

  role_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  tags             = local.tags
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.17.0"

  cluster_name                    = var.name
  cluster_version                 = "1.22"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # We are using the IRSA created below for permissions
  # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
  # and then turn this off after the cluster/node group is created. Without this initial policy,
  # the VPC CNI fails to assign IPs and nodes cannot join the cluster
  # See https://github.com/aws/containers-roadmap/issues/1666 for more context
  # TODO - remove this policy once AWS releases a managed version similar to AmazonEKS_CNI_Policy (IPv4)
  # create_cni_ipv6_iam_policy = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  vpc_id     = local.vpc_id
  subnet_ids = local.public_subnet_ids

  eks_managed_node_groups = {

    # Default node group - as provided by AWS EKS using Bottlerocket
    bottlerocket_default = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      create_launch_template = false
      launch_template_name   = ""

      ami_type       = "BOTTLEROCKET_x86_64"
      platform       = "bottlerocket"
      instance_types = ["c5.xlarge"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      capacity_type        = "SPOT"
      force_update_version = true
    }
  }
}


resource "aws_secretsmanager_secret" "cloudquery_secret" {
  name                    = var.name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "cloudquery_secret_version" {
  secret_id     = aws_secretsmanager_secret.cloudquery_secret.id
  secret_string = "postgres://${module.rds.cluster_master_username}:${module.rds.cluster_master_password}@${module.rds.cluster_endpoint}/postgres"
}

data "aws_secretsmanager_secret_version" "cloudquery_secret_version" {
  secret_id = aws_secretsmanager_secret.cloudquery_secret.id
  depends_on = [
    aws_secretsmanager_secret_version.cloudquery_secret_version
  ]
}

# This is to access the secret and put it as an environment variable
# once cloudquery supports HCP Vault, AWS Secret manager, GCP Secret natively
# we can remove this. See 


module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4"

  name        = "${var.name}-secretsmanager"
  path        = "/"
  description = "Access to CloudQuery secrets in AWS secret manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
      "Effect": "Allow",
      "Resource": "${aws_secretsmanager_secret_version.cloudquery_secret_version.arn}"
    }
  ]
}
EOF
}

######
# RDS
######

resource "aws_db_parameter_group" "cloudquery" {
  name        = "${var.name}-aurora-db-parameter-group"
  family      = var.postgres_family
  description = "${var.name}-aurora-db-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "cloudquery" {
  name        = "${var.name}-aurora-cluster-parameter-group"
  family      = var.postgres_family
  description = "${var.name}-aurora-cluster-parameter-group"
  tags        = local.tags
}

module "rds" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 7.1.0"

  name = var.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine         = "aurora-postgresql"
  engine_version = var.postgres_engine_version
  instance_class = var.postgres_instance_class
  instances = {
    one = {}
  }
  # db_name                = "cloudquery"
  # username               = "cloudquery"
  # port                   = "5432"

  performance_insights_enabled = true
  vpc_security_group_ids       = [module.security_group.security_group_id]
  vpc_id                       = local.vpc_id
  db_subnet_group_name         = local.database_subnet_group
  create_db_subnet_group       = false


  iam_database_authentication_enabled = true
  create_random_password              = true

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.cloudquery.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cloudquery.id
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = var.tags
}