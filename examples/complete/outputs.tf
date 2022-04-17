# VPC
output "vpc_id" {
  description = "ID of the VPC that was created or passed in"
  value       = module.cloudquery.vpc_id
}

# CQ
output "config" {
  description = "Path to the CloudQuery config.hcl"
  value       = file("${path.cwd}/config.hcl")
}