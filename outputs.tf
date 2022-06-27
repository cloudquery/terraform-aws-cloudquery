#---------------------------------------------------
# RDS
#---------------------------------------------------
output "rds_cluster_master_password" {
  description = "Master password for cloudquery rds database"
  value       = module.rds.cluster_master_password
  sensitive   = true
}

#---------------------------------------------------
# VPC
#---------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC that was created or passed in"
  value       = local.vpc_id
}

#---------------------------------------------------
# EKS
#---------------------------------------------------
output "irsa_arn" {
  description = "ARN of IRSA - (IAM Role for service account)"
  value       = module.cluster_irsa.iam_role_arn
}

output "irsa_name" {
  description = "Name of IRSA - (IAM Role for service account)"
  value       = module.cluster_irsa.iam_role_name
}


output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = module.eks.cluster_id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = module.eks.oidc_provider_arn
}

output "eks_cluster_status" {
  description = "Amazon EKS Cluster Status"
  value       = module.eks.cluster_status
}

output "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks.cluster_version
}


# CloudQuery
# output "cq_dsn" {
#   description = "CQ_DSN variable for CloudQuery CLI"
#   value       = "postgres://${module.rds.cluster_master_username}:${module.rds.cluster_master_password}@${module.rds.cluster_endpoint}/${module.rds.cluster_database_name}"
#   sensitive   = true
# }
