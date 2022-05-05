# RDS
# output "rds_cluster_master_password" {
#   description = "Master password for cloudquery rds database"
#   value       = module.rds.db_instance_password
#   sensitive   = true
# }

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
#   value       = "postgres://${module.rds.db_instance_username}:${module.rds.db_instance_password}@${module.rds.db_instance_endpoint}/${module.rds.db_instance_name}"
#   sensitive   = true
# }