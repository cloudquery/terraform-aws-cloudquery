data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "cloudquery" {
  for_each = toset(var.install_helm_chart ? ["cloudquery"] : [])
  name             = "cloudquery"
  namespace        = "cloudquery"
  repository       = "https://cloudquery.github.io/helm-charts"
  chart            = "cloudquery"
  version          = "0.1.3"
  create_namespace = true
  wait = true

  set {
    name  = "endRenderSecret.CQ_VAR_DSN"
    value = "postgres://${module.rds.db_instance_name}:${module.rds.db_instance_password}@${module.rds.db_instance_endpoint}:${module.rds.db_instance_port}"
  }

  depends_on = [
    module.eks.cluster_id,
  ]
}