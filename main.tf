resource "ec_deployment" "elastic_cloud_deployment" {
  name = var.project_name == null ? "${var.project_id}_deployment" : "${var.project_name}_deployment"

  region                 = "gcp-${var.region}"
  version                = var.elastic_version
  deployment_template_id = var.elastic_deployment_template_name

  traffic_filter = [
    ec_deployment_traffic_filter.filter_vpn_ips.id,
    ec_deployment_traffic_filter.filter_gcp_psc.id
  ]

  elasticsearch {
    dynamic "topology" {
      for_each = var.elastic_topology
      content {
        id         = topology.value.id
        size       = topology.value.size
        zone_count = topology.value.zone_count
        autoscaling {
          max_size = topology.value.autoscaling.max_size
        }
      }
    }
  }

  kibana {}
}

# Filter rule to allow requests from Dapper VPN IPs
resource "ec_deployment_traffic_filter" "filter_vpn_ips" {
  name   = var.project_name == null ? "${var.project_id} - VPN Traffic Filter Rules" : "${var.project_name} - VPN Traffic Filter Rules"
  region = "gcp-${var.region}"
  type   = "ip"

  dynamic "rule" {
    for_each = local.vpn_ips
    iterator = ips
    content {
      source = ips.value
    }
  }
}

# Filter rule to allow requests from associated GKE cluster
resource "ec_deployment_traffic_filter" "filter_gcp_psc" {

  name   = var.project_name == null ? "${var.project_id} - K8s Traffic Filter Rules" : "${var.project_name} - K8s Traffic Filter Rules"
  region = "gcp-${var.region}"
  type   = "gcp_private_service_connect_endpoint"

  rule {
    source = var.private_service_connect_id
  }
}
