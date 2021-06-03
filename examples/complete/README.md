# Complete CloudQuery example

Configuration in this directory creates the necessary infrastructure and deploy CloudQuery service there.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply -target="module.cloudquery.local_file.dockerfile[0]"
$ terraform apply
```


⚠️ This example will create resources which cost money. Run `terraform destroy` when you don't need these resources. ⚠️

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.68 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | >= 2.8.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.68 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudquery"></a> [cloudquery](#module\_cloudquery) | ../../ |  |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cq_dsn"></a> [cq\_dsn](#output\_cq\_dsn) | CQ\_DSN variable for CloudQuery CLI |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the VPC private subnets that were created or passed in |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the VPC public subnets that were created or passed in |
| <a name="output_rds_cluster_master_password"></a> [rds\_cluster\_master\_password](#output\_rds\_cluster\_master\_password) | Master password for cloudquery aurora database |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC that was created or passed in |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
