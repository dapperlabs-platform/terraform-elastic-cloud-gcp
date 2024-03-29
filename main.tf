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
    // If a topology is set, this ensures autoscaling will be turned off since turning on autoscaling when a topology is set causes
    // issues with the Elastic Cloud provider. Issue: https://github.com/elastic/terraform-provider-ec/issues/467
    autoscale = var.elastic_autoscaling && length(var.elastic_topology) == 0
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

  dynamic "observability" {
    for_each = var.observability_deployment == null ? toset([]) : toset([1])
    content {
      deployment_id = var.observability_deployment
    }
  }

  lifecycle {
    ignore_changes = [
      version,
    ]
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

resource "random_password" "additional_user_passwords" {
  for_each = toset(keys(var.additional_users))
  length   = 42
  upper    = true
  lower    = true
  numeric  = true
  special  = false
}

resource "elasticstack_elasticsearch_security_user" "additional_users" {
  for_each = var.additional_users

  username = each.key
  password = random_password.additional_user_passwords[each.key].result
  roles    = each.value
  elasticsearch_connection {
    endpoints = ["${ec_deployment.elastic_cloud_deployment.elasticsearch[0].https_endpoint}"]
    username  = ec_deployment.elastic_cloud_deployment.elasticsearch_username
    password  = ec_deployment.elastic_cloud_deployment.elasticsearch_password
  }

  depends_on = [
    ec_deployment_traffic_filter.filter_allowed_ips
  ]
}
