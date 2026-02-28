output "elasticsearch_endpoint" {
  description = "Elasticsearch endpoint"
  value       = "http://elasticsearch-master.logging.svc.cluster.local:9200"
}

output "kibana_endpoint" {
  description = "Kibana endpoint"
  value       = "http://kibana-kibana.logging.svc.cluster.local:5601"
}

output "vector_status" {
  description = "Vector deployment status"
  value       = "deployed"
}