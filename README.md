# Terraform module which runs CloudQuery on AWS Lambda

[CloudQuery](https://www.cloudquery.io/) is tool to query your cloud assets & configuration with SQL. Solve compliance, security and cost challenges with standard SQL queries and relational tables.

This repository contains Terraform infrastructure code which creates AWS resources required to run [CloudQuery](https://www.cloudquery.io/) on AWS, including:

- Virtual Private Cloud (VPC)
- Aurora RDS serverless (version 1)
- Lambda function created from ECR image
- ECR repository where Docker Image is being copied from the official registry
- AWS Parameter Store to keep secrets and access them from Lambda function


## How to use this?

There are three ways to get started with CloudQuery:

1. [As a standalone project](https://github.com/cloudquery/terraform-aws-cloudquery#run-atlantis-as-a-standalone-project)
1. [As a Terraform module](https://github.com/cloudquery/terraform-aws-cloudquery#run-atlantis-as-a-terraform-module)
1. [As a part of an existing AWS infrastructure](https://github.com/cloudquerys/terraform-aws-cloudquery#run-atlantis-as-a-part-of-an-existing-aws-infrastructure-use-existing-vpc)


### Run CloudQuery as a standalone project

1. Clone this github repository:

```
$ git clone git@github.com:cloudquery/terraform-aws-cloudquery.git
$ cd cloudquery
```

2. Copy sample `terraform.tfvars.sample` into `terraform.tfvars` and specify required variables there.

3. Run `terraform init` to download required providers and modules.

4. Run `terraform apply` to apply the Terraform configuration and create required infrastructure.

5. Run `terraform output cq_dsn` to get the value of `CQ_DSN` environment value. Note: It is not possible to connect to RDS database in AWS from outside. See AWS documentation for various connectivity options.

5. See official documentation on [https://docs.cloudquery.io/](https://docs.cloudquery.io/) for more details.


### Run CloudQuery as a Terraform module

This way allows integration with your existing Terraform configurations. See available inputs below.

```hcl
module "cloudquery" {
  source  = "cloudquery/cloudquery/aws"
  version = "~> 0.0"

  name = "cloudquery"

  cidr             = "10.20.0.0/16"
  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets   = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  database_subnets = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
}
```

### Run CloudQuery as a part of an existing AWS infrastructure (use existing VPC)

This way allows integration with your existing AWS resources - VPC, public and database subnets. Specify the following arguments (see methods described above):

```
vpc_id              = "vpc-1651acf1"
public_subnet_ids   = ["subnet-1211eef5", "subnet-163466ab"]
database_subnet_ids = ["subnet-1fe3d837", "subnet-129d66ab"]
```

If `vpc_id` is specified it will take precedence over `cidr` and existing VPC will be used. `database_subnet_ids` and `public_subnet_ids` must be specified also.

Make sure that both private and public subnets were created in the same set of availability zones.


## Known issues

During creation of the infrastructure you can get such error:

```
Error: Provider produced inconsistent final plan
│ 
│ When expanding the plan for docker_registry_image.cloudquery[0] to include new values
│ learned so far during apply, provider "registry.terraform.io/kreuzwerker/docker" produced an invalid new value for .build[0].context ...
╵
```

The easiest solution is to rerun `terraform apply` one more time.

Alternatively, you can perform target apply to create required `Dockerfile` resource before building Docker image, like this:

```
# When using as a module:
$ terraform apply -target="module.cloudquery.local_file.dockerfile[0]"

# When using as a complete project:
$ terraform apply -target="local_file.dockerfile[0]"

# Proceed with the rest of resources
$ terraform apply
```

## Examples

- [Complete CloudQuery example](https://github.com/cloudquery/terraform-aws-cloudquery/tree/main/examples/complete)
- [Custom CloudQuery Docker Image example](https://github.com/cloudquery/terraform-aws-cloudquery/tree/main/examples/custom-image)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.68 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | >= 2.8.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.68 |
| <a name="provider_docker"></a> [docker](#provider\_docker) | >= 2.8.0 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eventbridge"></a> [eventbridge](#module\_eventbridge) | terraform-aws-modules/eventbridge/aws | ~> 1.0 |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | terraform-aws-modules/lambda/aws | ~> 2.0 |
| <a name="module_lambda_sg"></a> [lambda\_sg](#module\_lambda\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds-aurora/aws | ~> 5.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.cloudquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [docker_registry_image.cloudquery](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/registry_image) | resource |
| [local_file.dockerfile](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_password.master_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_ecr_repository.cloudquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aurora_auto_pause"></a> [aurora\_auto\_pause](#input\_aurora\_auto\_pause) | Whether to autopause Aurora database when there is no activity | `bool` | `true` | no |
| <a name="input_aurora_engine_version"></a> [aurora\_engine\_version](#input\_aurora\_engine\_version) | Version of Amazon Aurora Postgres Serverless v1. Verify availability in your region here - https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraFeaturesRegionsDBEngines.grids.html#Concepts.Aurora_Fea_Regions_DB-eng.Feature.Serverless | `string` | `"10.12"` | no |
| <a name="input_aurora_max_capacity"></a> [aurora\_max\_capacity](#input\_aurora\_max\_capacity) | Maximum capacity for Aurora database | `number` | `4` | no |
| <a name="input_aurora_min_capacity"></a> [aurora\_min\_capacity](#input\_aurora\_min\_capacity) | Minimum capacity for Aurora database | `number` | `2` | no |
| <a name="input_aurora_seconds_until_auto_pause"></a> [aurora\_seconds\_until\_auto\_pause](#input\_aurora\_seconds\_until\_auto\_pause) | Number of seconds before autopause for Aurora database | `number` | `300` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones in the region | `list(string)` | `[]` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC which will be created if `vpc_id` is not specified | `string` | `""` | no |
| <a name="input_cloudquery_fetch_schedule"></a> [cloudquery\_fetch\_schedule](#input\_cloudquery\_fetch\_schedule) | Schedule to run cloudquery fetch command | `string` | `"rate(1 hour)"` | no |
| <a name="input_cloudquery_image"></a> [cloudquery\_image](#input\_cloudquery\_image) | CloudQuery Docker Image URI to deploy Lambda function from. If not specified, official CloudQuery image will be copied into ECR repository and used | `string` | `""` | no |
| <a name="input_cloudquery_version"></a> [cloudquery\_version](#input\_cloudquery\_version) | Version of CloudQuery to run. If not specified latest will be used | `string` | `"latest"` | no |
| <a name="input_create_ecr_repository"></a> [create\_ecr\_repository](#input\_create\_ecr\_repository) | Whether to create ECR repository or use an existing one | `bool` | `true` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | Name of ECR repository to create or use an existing one | `string` | `"cloudquery"` | no |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | Lambda function memory size | `number` | `1024` | no |
| <a name="input_lambda_security_group_tags"></a> [lambda\_security\_group\_tags](#input\_lambda\_security\_group\_tags) | Additional tags to put on Lambda security group | `map(string)` | `{}` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda function timeout | `number` | `60` | no |
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

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/cloudquery/terraform-aws-cloudquery/tree/main/LICENSE) for full details.
