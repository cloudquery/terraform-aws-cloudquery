locals {
  # VPC - existing or new?
  vpc_id            = var.vpc_id == "" ? module.vpc.vpc_id : var.vpc_id
  public_subnet_ids = coalescelist(module.vpc.public_subnets, var.public_subnet_ids, [""])
  # private_subnet_ids          = coalescelist(module.vpc.private_subnets, var.private_subnet_ids, [""])
  private_subnets_cidr_blocks = coalescelist(module.vpc.private_subnets_cidr_blocks, var.private_subnets_cidr_blocks, [""])

  # cq_dsn = "user=${module.rds.rds_cluster_master_username} password=${module.rds.rds_cluster_master_password} host=${module.rds.rds_cluster_endpoint} port=${module.rds.rds_cluster_port} dbname=${module.rds.rds_cluster_database_name}"

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
  cidr = var.cidr

  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

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
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

######
# EKS
######

module "cluster_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.18"

  role_name = "cloudquery-eksa-irsa"

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      # this expects namespace:service_account_name
      namespace_service_accounts = ["cloudquery:cloudquery"]
    }
  }

  role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.17.0"

  cluster_name                    = var.name
  cluster_version                 = "1.21"
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

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 100
    instance_types         = ["m5.large"]
    vpc_security_group_ids = [module.security_group.security_group_id]

    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      create_launch_template = false
      launch_template_name   = ""
      max_size               = 1
      desired_size           = 1
    }

    # Default node group - as provided by AWS EKS using Bottlerocket
    bottlerocket_default = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      create_launch_template = false
      launch_template_name   = ""

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
    }
  }

}


######
# RDS
######

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 4.2.0"

  identifier = var.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = var.postgres_engine_version
  family               = var.postgres_family
  major_engine_version = var.postgres_major_engine_version
  instance_class       = var.postgres_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name                = "cloudquery"
  username               = "cloudquery"
  port                   = "5432"
  create_random_password = true

  vpc_id = local.vpc_id

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]
  allowed_cidr_blocks    = local.private_subnets_cidr_blocks


  maintenance_window              = "Sun:00:00-Sun:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "cloudquery-monitoring"
  monitoring_role_description           = "Monitoring CloudQuery RDS"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = var.tags
}