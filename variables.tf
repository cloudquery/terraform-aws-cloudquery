variable "name" {
  description = "Name to use on all resources created (VPC, RDS, etc)"
  type        = string
  default     = "cloudquery"
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

# Helm

variable "install_helm_chart" {
  description = "Enable/Disable helm chart installation"
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "The version of CloudQuery helm chart"
  type        = string
  default     = "0.2.3"
}

# variable "chart_version" {
#   description = "The version of CloudQuery helm chart"
#   type        = string
#   default     = "0.1.3"
# }

variable "config_file" {
  description = "Path to the CloudQuery config.hcl"
  type        = string
  default     = ""
}

variable "chart_values" {
  description = "Variables to pass to the helm chart"
  type        = string
  default     = ""
}


# VPC
variable "vpc_id" {
  description = "ID of an existing VPC where resources will be created"
  type        = string
  default     = null
}

variable "public_subnet_ids" {
  description = "A list of IDs of existing public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnet_group" {
  description = "If vpc_id is specified, path the subnet_group name where the RDS should reside"
  type        = string
  default     = ""
}

# RDS
variable "postgres_engine_version" {
  description = "Version of Amazon RDS Postgres engine to use"
  type        = string
  default     = "14.2"
}

variable "postgres_family" {
  description = "Family of Amazon RDS Postgres engine to use"
  type        = string
  default     = "postgres14"
}

variable "postgres_major_engine_version" {
  description = "Major version of Amazon RDS Postgres engine to use"
  type        = string
  default     = "14"
}

variable "postgres_instance_class" {
  description = "Postgresql Instance Class"
  type        = string
  default     = "db.t4g.large"
}

# EKS
# role_policy_arns
variable "role_policy_arns" {
  description = "Policies for the role to use for the EKS service account"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}