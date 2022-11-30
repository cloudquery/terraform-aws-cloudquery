# CloudQuery AWS Module

This folder contains a Terraform module to deploy a CloudQuery cluster in AWS on top of EKS.

## Usage

Examples are included in the example folder, but simple usage is as follows:

```hcl
module "cloudquery" {
  source = "cloudquery/cloudquery/aws"
  version = "~> 0.5"

  name = "cloudquery"

  cidr = "10.20.0.0/16"
  azs  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  private_subnets = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
  database_subnets = ["10.10.21.0/24", "10.10.22.0/24"]

  # path to your cloudquery config
  config_file = "config.yml"

}
```

### Existing VPC

This way allows integration with your existing AWS resources - VPC, public and private subnets. Specify the following arguments (see methods described above):

If vpc_id is specified it will take precedence over cidr and existing VPC will be used.

Make sure that both private and public subnets were created in the same set of availability zones.

### Run Helm Separately

## Examples

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.15 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.15 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.5 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_irsa"></a> [cluster\_irsa](#module\_cluster\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 4.20 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 18.30.0 |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | ~> 4 |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds-aurora/aws | ~> 7.6.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | ~> 4.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_parameter_group.cloudquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_iam_role_policy_attachment.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_rds_cluster_parameter_group.cloudquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_secretsmanager_secret.cloudquery_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.cloudquery_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [helm_release.cloudquery](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [random_password.rds](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_secretsmanager_secret_version.cloudquery_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_vpc.cq_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | If RDS is publicly accessible it is highly advised to specify allowed cidrs from where you are planning to connect | `list(string)` | `[]` | no |
| <a name="input_chart_values"></a> [chart\_values](#input\_chart\_values) | Variables to pass to the helm chart | `string` | `""` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The version of CloudQuery helm chart | `string` | `"5.1.11"` | no |
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | Path to the CloudQuery config.yml | `string` | `""` | no |
| <a name="input_database_subnet_group"></a> [database\_subnet\_group](#input\_database\_subnet\_group) | If vpc\_id is specified, path the subnet\_group name where the RDS should reside | `string` | `""` | no |
| <a name="input_install_helm_chart"></a> [install\_helm\_chart](#input\_install\_helm\_chart) | Enable/Disable helm chart installation | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to use on all resources created (VPC, RDS, etc) | `string` | `"cloudquery"` | no |
| <a name="input_postgres_engine_version"></a> [postgres\_engine\_version](#input\_postgres\_engine\_version) | Version of Amazon RDS Postgres engine to use | `string` | `"13.6"` | no |
| <a name="input_postgres_family"></a> [postgres\_family](#input\_postgres\_family) | Family of Amazon RDS Postgres engine to use | `string` | `"aurora-postgresql13"` | no |
| <a name="input_postgres_instance_class"></a> [postgres\_instance\_class](#input\_postgres\_instance\_class) | Postgresql Instance Class | `string` | `"db.t3.medium"` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | A list of IDs of existing public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Make RDS publicly accessible (might be needed if you want to connect to it from Grafana or other tools). | `bool` | `false` | no |
| <a name="input_role_policy_arns"></a> [role\_policy\_arns](#input\_role\_policy\_arns) | Policies for the role to use for the EKS service account | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/ReadOnlyAccess"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to use on all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of an existing VPC where resources will be created | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_values"></a> [helm\_values](#output\_helm\_values) | Helm values for the cluster |
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | ARN of IRSA - (IAM Role for service account) |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | Name of IRSA - (IAM Role for service account) |
| <a name="output_rds_cluster_master_password"></a> [rds\_cluster\_master\_password](#output\_rds\_cluster\_master\_password) | Master password for cloudquery rds database |
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
