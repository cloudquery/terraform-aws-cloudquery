# RDS
output "rds_cluster_master_password" {
  description = "Master password for cloudquery aurora database"
  value       = module.cloudquery.rds_cluster_master_password
}

# VPC
output "vpc_id" {
  description = "ID of the VPC that was created or passed in"
  value       = module.cloudquery.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the VPC public subnets that were created or passed in"
  value       = module.cloudquery.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the VPC private subnets that were created or passed in"
  value       = module.cloudquery.private_subnet_ids
}

# CloudQuery
output "cq_dsn" {
  description = "CQ_DSN variable for CloudQuery CLI"
  value       = module.cloudquery.cq_dsn
}
