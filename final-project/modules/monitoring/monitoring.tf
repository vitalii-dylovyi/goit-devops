# Prometheus — metrics collection + alerting
resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = var.namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  version          = var.prometheus_chart_version
  create_namespace = true
}

# Grafana — visualization, pre-wired with Prometheus as a data source
resource "helm_release" "grafana" {
  name             = "grafana"
  namespace        = var.namespace
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = var.grafana_chart_version
  create_namespace = false

  set_sensitive {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  values = [
    <<-YAML
    datasources:
      datasources.yaml:
        apiVersion: 1
        datasources:
          - name: Prometheus
            type: prometheus
            url: http://prometheus-server.${var.namespace}.svc:80
            access: proxy
            isDefault: true
    YAML
  ]

  depends_on = [helm_release.prometheus]
}
