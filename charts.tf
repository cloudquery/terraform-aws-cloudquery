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
  for_each         = toset(var.install_helm_chart ? ["cloudquery"] : [])
  name             = var.name
  namespace        = "cloudquery"
  repository       = "https://cloudquery.github.io/helm-charts"
  chart            = "cloudquery"
  version          = var.chart_version
  create_namespace = true
  wait             = true
  values = [
<<EOT
serviceAccount:
  enabled: true
  annotations:
    "eks.amazonaws.com/role-arn": ${module.cluster_irsa.iam_role_arn}
ascp:
  enabled: true
  secrets: ["CQ_VAR_DSN"]
config: |
  ${indent(2, file(var.config_file))}
EOT
,
  var.chart_values
]

  depends_on = [
    module.eks.cluster_id,
  ]
}