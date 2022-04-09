# Terraform modules to deploy CloudQuery

[CloudQuery](https://www.cloudquery.io/) is an open-source cloud asset inventory.

This repository contains Terraform infrastructure code which creates resources required to run [CloudQuery](https://www.cloudquery.io/), including:

- [AWS EKS + RDS](./modules/eks/README.md)
- [AWS Lambda (serverless)](./modules/lambda/README.md) - now deprecated


## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/cloudquery/terraform-aws-cloudquery/tree/main/LICENSE) for full details.
