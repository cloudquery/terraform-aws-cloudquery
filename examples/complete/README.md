# Complete (Infrastructure + Helm)

The configuration in this directory create complete setup of CloudQuery on top of EKS, RDS, Secret Manager and helm charts installed.

## Usage

```
terraform init
terraform plan
aws --region us-east-1 eks update-kubeconfig --name cloudquery-complete-example
# This should print helpers from the helm
helm get notes cloudquery-complete-example --namespace cloudquery

# exec into cloudquery-admin pod
kubectl exec -it deployment/cloudquery-complete-example-admin -n cloudquery -- /bin/sh

# uninstall cloudquery
helm uninstall cloudquery-complete-example -n cloudquery
```