# Custom CloudQuery Docker Image example

Configuration in this directory created custom Docker Image and pushes it to private ECR.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Then specify `image_name` value as an argument for the main module, like this:

```
module "cloudquery" {

  # omitted for brevity... see `examples/complete`
  
  use_existing_ecr_image = true
  cloudquery_image       = "835367812851.dkr.ecr.eu-west-1.amazonaws.com/cloudquery-custom:0.13.5"
}
```

⚠️ This example will create resources which cost money. Run `terraform destroy` when you don't need these resources. ⚠️

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.68 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | >= 2.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.68 |
| <a name="provider_docker"></a> [docker](#provider\_docker) | >= 2.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.cloudquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [docker_registry_image.cloudquery](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/registry_image) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_name"></a> [image\_name](#output\_image\_name) | Docker Image URI |
| <a name="output_image_sha256_digest"></a> [image\_sha256\_digest](#output\_image\_sha256\_digest) | Git repositories where webhook should be created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
