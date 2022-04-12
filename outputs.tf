output "elasticsearch_password" {
  value     = ec_deployment.elastic_cloud_deployment.elasticsearch_password
  sensitive = true
}

output "elasticsearch_user" {
  value = ec_deployment.elastic_cloud_deployment.elasticsearch_username
}

output "elasticsearch_https_endpoint" {
  value = ec_deployment.elastic_cloud_deployment.elasticsearch[0].https_endpoint
}

output "kibana_endpoint" {
  value = ec_deployment.elastic_cloud_deployment.kibana[0].https_endpoint
}
