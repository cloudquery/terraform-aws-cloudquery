# RDS
output "rds_cluster_master_password" {
  description = "Master password for cloudquery rds database"
  value       = module.rds.cluster_master_password
  sensitive   = true
}

# VPC
output "vpc_id" {
  description = "ID of the VPC that was created or passed in"
  value       = local.vpc_id
}

# EKS
output "irsa_arn" {
  description = "ARN of IRSA - (IAM Role for service account)"
  value       = module.cluster_irsa.iam_role_arn
}

output "irsa_name" {
  description = "Name of IRSA - (IAM Role for service account)"
  value       = module.cluster_irsa.iam_role_name
}

# CloudQuery
# output "cq_dsn" {
#   description = "CQ_DSN variable for CloudQuery CLI"
#   value       = "postgres://${module.rds.cluster_master_username}:${module.rds.cluster_master_password}@${module.rds.cluster_endpoint}/${module.rds.cluster_database_name}"
#   sensitive   = true
# }