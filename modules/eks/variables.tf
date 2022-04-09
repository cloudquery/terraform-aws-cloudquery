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
  default     = false
}

variable "chart_version" {
  description = "The version of CloudQuery helm chart"
  type        = string
  default     = "0.1.3"
}

# variable "chart_version" {
#   description = "The version of CloudQuery helm chart"
#   type        = string
#   default     = "0.1.3"
# }

variable "config_file" {
  description = "Path to the CloudQuery config.hcl"
  type        = string
  nullable    = false
  default     = ""
}

variable "chart_variables" {
  description = "Variables to pass to the helm chart"
  type        = map(string)
  default     = {}
}


# VPC
variable "vpc_id" {
  description = "ID of an existing VPC where resources will be created"
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "A list of IDs of existing public subnets inside the VPC"
  type        = list(string)
  default     = []
}

# variable "private_subnet_ids" {
#   description = "A list of IDs of existing private subnets inside the VPC"
#   type        = list(string)
#   default     = []
# }

# variable "private_subnets_cidr_blocks" {
#   description = "A list of CIDR blocks of private subnets inside the VPC to allow access to RDS database"
#   type        = list(string)
#   default     = []
# }

variable "cidr" {
  description = "The CIDR block for the VPC which will be created if `vpc_id` is not specified"
  type        = string
  default     = ""
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "A list of database subnets inside the VPC"
  type        = list(string)
  default     = []
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

