# CloudQuery AWS Module

This folder contains a Terraform module to deploy a CloudQuery cluster in AWS on top of EKS.

## Usage 

Examples are included in the example folder, but simple usage is as follows:

```hcl
module "cloudquery" {
  source = "cloudquery/cloudquery/aws"
  version = "~> 0.4"

  name = "cloudquery"

  cidr = "10.20.0.0/16"
  azs  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  private_subnets = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
  database_subnets = ["10.10.21.0/24", "10.10.22.0/24"]
  
  # path to your cloudquery config
  config_file = "config.hcl"
  
}
```

### Existing VPC

This way allows integration with your existing AWS resources - VPC, public and private subnets. Specify the following arguments (see methods described above):


If vpc_id is specified it will take precedence over cidr and existing VPC will be used.

Make sure that both private and public subnets were created in the same set of availability zones.

### Run Helm Seperately

## Examples

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.68 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.68 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds-aurora/aws | ~> 5.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.cloudquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [docker_registry_image.cloudquery](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/registry_image) | resource |
| [local_file.dockerfile](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_ecr_repository.cloudquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aurora_auto_pause"></a> [aurora\_auto\_pause](#input\_aurora\_auto\_pause) | Whether to autopause Aurora database when there is no activity | `bool` | `true` | no |
| <a name="input_aurora_engine_version"></a> [aurora\_engine\_version](#input\_aurora\_engine\_version) | Version of Amazon Aurora Postgres Serverless v1. Verify availability in your region here - https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraFeaturesRegionsDBEngines.grids.html#Concepts.Aurora_Fea_Regions_DB-eng.Feature.Serverless | `string` | `"13.4"` | no |
| <a name="input_aurora_max_capacity"></a> [aurora\_max\_capacity](#input\_aurora\_max\_capacity) | Maximum capacity for Aurora database | `number` | `4` | no |
| <a name="input_aurora_min_capacity"></a> [aurora\_min\_capacity](#input\_aurora\_min\_capacity) | Minimum capacity for Aurora database | `number` | `2` | no |
| <a name="input_aurora_seconds_until_auto_pause"></a> [aurora\_seconds\_until\_auto\_pause](#input\_aurora\_seconds\_until\_auto\_pause) | Number of seconds before autopause for Aurora database | `number` | `300` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones in the region | `list(string)` | `[]` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC which will be created if `vpc_id` is not specified | `string` | `""` | no |
| <a name="input_cloudquery_fetch_schedule"></a> [cloudquery\_fetch\_schedule](#input\_cloudquery\_fetch\_schedule) | Schedule to run cloudquery fetch command | `string` | `"rate(5 hours)"` | no |
| <a name="input_cloudquery_image"></a> [cloudquery\_image](#input\_cloudquery\_image) | CloudQuery Docker Image URI to deploy Lambda function from. If not specified, official CloudQuery image will be copied into ECR repository and used | `string` | `""` | no |
| <a name="input_cloudquery_version"></a> [cloudquery\_version](#input\_cloudquery\_version) | Version of CloudQuery to run. If not specified latest will be used | `string` | `"latest"` | no |
| <a name="input_create_ecr_repository"></a> [create\_ecr\_repository](#input\_create\_ecr\_repository) | Whether to create ECR repository or use an existing one | `bool` | `true` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | Name of ECR repository to create or use an existing one | `string` | `"cloudquery"` | no |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | Lambda function memory size | `number` | `2048` | no |
| <a name="input_lambda_security_group_tags"></a> [lambda\_security\_group\_tags](#input\_lambda\_security\_group\_tags) | Additional tags to put on Lambda security group | `map(string)` | `{}` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda function timeout | `number` | `900` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to use on all resources created (VPC, RDS, etc) | `string` | `"cloudquery"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | A list of IDs of existing private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#input\_private\_subnets\_cidr\_blocks) | A list of CIDR blocks of private subnets inside the VPC to allow access to RDS database | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | A list of IDs of existing public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to use on all resources | `map(string)` | `{}` | no |
| <a name="input_use_existing_ecr_image"></a> [use\_existing\_ecr\_image](#input\_use\_existing\_ecr\_image) | Whether to deploy an existing Docker image from private ECR repository. Default is to copy from the official source Docker image. | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of an existing VPC where resources will be created | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cq_dsn"></a> [cq\_dsn](#output\_cq\_dsn) | CQ\_DSN variable for CloudQuery CLI |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the VPC private subnets that were created or passed in |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the VPC public subnets that were created or passed in |
| <a name="output_rds_cluster_master_password"></a> [rds\_cluster\_master\_password](#output\_rds\_cluster\_master\_password) | Master password for cloudquery aurora database |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC that was created or passed in |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Troubleshooting

If helm installtion is stuck in some hanging state you can run the following commands:

```bash
# check if helm is installed in cloudquery namespace
helm ls -n cloudquery
# If yes uninstall with the your release name
helm uninstall YOUR_RELEASE_NAME -n cloudquery
```

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) and [CloudQuery Team](https://github.com/cloudquery/cloudquery).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/cloudquery/terraform-aws-cloudquery/tree/main/LICENSE) for full details.
