resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "8.5.1"

  namespace        = "logging"
  create_namespace = true

  set {
    name  = "replicas"
    value = "3"
  }

  set {
    name  = "minimumMasterNodes"
    value = "2"
  }

  set {
    name  = "resources.requests.memory"
    value = "2Gi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "1000m"
  }

  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = "30Gi"
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "8.5.1"

  namespace = "logging"

  set {
    name  = "elasticsearchHosts"
    value = "http://elasticsearch-master:9200"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "500m"
  }

  depends_on = [helm_release.elasticsearch]
}

resource "helm_release" "vector" {
  name       = "vector"
  repository = "https://helm.vector.dev"
  chart      = "vector"
  version    = "0.27.0"

  namespace = "logging"

  values = [
    <<-EOT
    role: Agent
    
    customConfig:
      data_dir: /vector-data-dir
      
      sources:
        kubernetes_logs:
          type: kubernetes_logs
          namespace_annotation_fields:
            namespace_labels: ""
          node_annotation_fields:
            node_labels: ""
          pod_annotation_fields:
            pod_annotations: ""
            pod_labels: ""
      
      transforms:
        parse_logs:
          type: remap
          inputs:
            - kubernetes_logs
          source: |
            .application = .kubernetes.pod_labels.app
            .namespace = .kubernetes.pod_namespace
            .pod = .kubernetes.pod_name
            .container = .kubernetes.container_name
      
      sinks:
        elasticsearch:
          type: elasticsearch
          inputs:
            - parse_logs
          endpoint: http://elasticsearch-master:9200
          mode: bulk
          bulk:
            index: "kubernetes-logs-%Y.%m.%d"
          encoding:
            codec: json
          healthcheck:
            enabled: true
    EOT
  ]

  depends_on = [helm_release.elasticsearch]
}