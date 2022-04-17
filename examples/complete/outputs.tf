# VPC
output "vpc_id" {
  description = "ID of the VPC that was created or passed in"
  value       = module.cloudquery.vpc_id
}
