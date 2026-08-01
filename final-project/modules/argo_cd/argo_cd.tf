# Argo CD installed from the official Helm chart
resource "helm_release" "argo_cd" {
  name             = var.name
  namespace        = var.namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}

# Local chart that declares Argo CD Applications and Repositories
resource "helm_release" "argo_apps" {
  name             = "${var.name}-apps"
  chart            = "${path.module}/charts"
  namespace        = var.namespace
  create_namespace = false

  values = [
    templatefile("${path.module}/charts/values.yaml.tmpl", {
      github_username   = var.github_username
      github_pat        = var.github_pat
      db_host           = var.db_host
      db_password       = var.db_password
      django_secret_key = var.django_secret_key
    })
  ]

  depends_on = [helm_release.argo_cd]
}
