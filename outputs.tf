# RDS
output "rds_cluster_master_password" {
  description = "Master password for cloudquery aurora database"
  value       = nonsensitive(module.rds.rds_cluster_master_password)
  #  sensitive   = true
}

# VPC
output "vpc_id" {
  description = "ID of the VPC that was created or passed in"
  value       = local.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the VPC public subnets that were created or passed in"
  value       = local.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the VPC private subnets that were created or passed in"
  value       = local.private_subnet_ids
}

# CloudQuery
output "cq_dsn" {
  description = "CQ_DSN variable for CloudQuery CLI"
  value       = nonsensitive(local.cq_dsn)
}
