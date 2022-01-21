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

#variable "postgres_security_group_tags" {
#  description = "Additional tags to put on Postgres security group"
#  type        = map(string)
#  default     = {}
#}

variable "lambda_security_group_tags" {
  description = "Additional tags to put on Lambda security group"
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

variable "private_subnet_ids" {
  description = "A list of IDs of existing private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets_cidr_blocks" {
  description = "A list of CIDR blocks of private subnets inside the VPC to allow access to RDS database"
  type        = list(string)
  default     = []
}

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

# RDS
variable "aurora_engine_version" {
  description = "Version of Amazon Aurora Postgres Serverless v1. Verify availability in your region here - https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraFeaturesRegionsDBEngines.grids.html#Concepts.Aurora_Fea_Regions_DB-eng.Feature.Serverless"
  type        = string
  default     = "10.12"
}

variable "aurora_auto_pause" {
  description = "Whether to autopause Aurora database when there is no activity"
  type        = bool
  default     = true
}

variable "aurora_min_capacity" {
  description = "Minimum capacity for Aurora database"
  type        = number
  default     = 2
}

variable "aurora_max_capacity" {
  description = "Maximum capacity for Aurora database"
  type        = number
  default     = 4
}

variable "aurora_seconds_until_auto_pause" {
  description = "Number of seconds before autopause for Aurora database"
  type        = number
  default     = 300
}

# Lambda
variable "lambda_memory_size" {
  description = "Lambda function memory size"
  type        = number
  default     = 2048

  validation {
    condition     = can(var.lambda_memory_size > 128 && var.lambda_memory_size < 10240)
    error_message = "Memory size for Lambda function should be between 128 and 10240 (megabytes)."
  }
}

variable "lambda_timeout" {
  description = "Lambda function timeout"
  type        = number
  default     = 900

  validation {
    condition     = can(var.lambda_timeout > 0 && var.lambda_timeout < 900)
    error_message = "Timeout for Lambda function should be between 0 and 900 (seconds)."
  }
}

# ECR repository
variable "create_ecr_repository" {
  description = "Whether to create ECR repository or use an existing one"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name of ECR repository to create or use an existing one"
  type        = string
  default     = "cloudquery"
}

# CloudQuery
variable "use_existing_ecr_image" {
  description = "Whether to deploy an existing Docker image from private ECR repository. Default is to copy from the official source Docker image."
  type        = bool
  default     = false
}

variable "cloudquery_image" {
  description = "CloudQuery Docker Image URI to deploy Lambda function from. If not specified, official CloudQuery image will be copied into ECR repository and used"
  type        = string
  default     = ""
}

variable "cloudquery_version" {
  description = "Version of CloudQuery to run. If not specified latest will be used"
  type        = string
  default     = "latest"
}

variable "cloudquery_fetch_schedule" {
  description = "Schedule to run cloudquery fetch command"
  type        = string
  default     = "rate(5 hours)"
}

