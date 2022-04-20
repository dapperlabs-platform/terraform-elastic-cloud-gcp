# Taint this resource to update the cluster to a new version
data "ec_stack" "version" {
  version_regex = var.elastic_version_regex
  region        = "gcp-${var.region}"
  lock          = true # locks the version in place so as to not cause unecessary updates.
}

resource "ec_deployment" "elastic_cloud_deployment" {
  name = var.project_name == null ? "${var.project_id}_deployment" : "${var.project_name}_deployment"

  region                 = "gcp-${var.region}"
  version                = data.ec_stack.version.version
  deployment_template_id = var.elastic_deployment_template_name
  request_id             = var.request_id

  traffic_filter = var.make_public ? null : [
    ec_deployment_traffic_filter.filter_allowed_ips[0].id,
    ec_deployment_traffic_filter.filter_gcp_psc[0].id,
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
    dynamic "config" {
      for_each = var.enable_anonymous_access && !var.make_public ? [1] : []
      content {
        user_settings_yaml = file("${path.module}/elasticsearch.yml")
      }
    }
  }

  kibana {
    dynamic "topology" {
      for_each = var.kibana_topology
      content {
        size       = topology.value.size
        zone_count = topology.value.zone_count
      }
    }
  }
}

# Filter rule to allow requests from allowed IPs
resource "ec_deployment_traffic_filter" "filter_allowed_ips" {
  count = var.make_public ? 0 : 1

  name   = var.project_name == null ? "${var.project_id} - Allowed IPs Filter Rule" : "${var.project_name} - Allowed IPs Filter Rule"
  region = "gcp-${var.region}"
  type   = "ip"

  dynamic "rule" {
    for_each = var.allowed_ips
    iterator = ips
    content {
      source = ips.value
    }
  }
}

# Filter rule to allow requests from associated GKE cluster
resource "ec_deployment_traffic_filter" "filter_gcp_psc" {
  count = var.make_public ? 0 : 1

  name   = var.project_name == null ? "${var.project_id} - K8s Traffic Filter Rules" : "${var.project_name} - K8s Traffic Filter Rules"
  region = "gcp-${var.region}"
  type   = "gcp_private_service_connect_endpoint"

  rule {
    source = var.private_service_connect_id
  }
}

# Elasticsearch role that defines the accesses granted for anonymous access. Provides read access to most resources and edit access to indices.
resource "elasticstack_elasticsearch_security_role" "anonymous_role" {
  count = var.make_public || !var.enable_anonymous_access ? 0 : 1

  name    = "anonymous_role"
  cluster = ["monitor"]

  indices {
    names      = ["*"]
    privileges = ["all"]
  }

  elasticsearch_connection {
    endpoints = ["${ec_deployment.elastic_cloud_deployment.elasticsearch[0].https_endpoint}"]
    username  = ec_deployment.elastic_cloud_deployment.elasticsearch_username
    password  = ec_deployment.elastic_cloud_deployment.elasticsearch_password
  }

  depends_on = [
    ec_deployment_traffic_filter.filter_allowed_ips
  ]
}
