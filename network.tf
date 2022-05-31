# The VPC network
data "google_compute_network" "network" {
  count = var.disable_psc ? 0 : 1

  project = var.project_id
  name    = var.vpc_name
}

# We need this because the resource doesn't automatically export the IP address for some reason
data "google_compute_address" "psc_address" {
  count = var.disable_psc ? 0 : 1

  depends_on = [google_compute_address.psc_address[0]]

  name    = var.project_name == null ? "${var.project_id}-psc-address" : "${var.project_name}-psc-address"
  region  = var.region
  project = var.project_id
}

# Private Service connect IP Address
resource "google_compute_address" "psc_address" {
  count = var.disable_psc ? 0 : 1

  name         = var.project_name == null ? "${var.project_id}-psc-address" : "${var.project_name}-psc-address"
  region       = var.region
  address_type = "INTERNAL"
  project      = var.project_id
  subnetwork   = data.google_compute_network.network[0].subnetworks_self_links[0]
}

resource "google_compute_forwarding_rule" "psc_forwarding_rule" {
  name                  = var.project_name == null ? "${var.project_id}-psc-forwarding-rule" : "${var.project_name}-psc-forwarding-rule"
  load_balancing_scheme = ""
  region                = var.region
  project               = var.project_id
  ip_address            = google_compute_address.psc_address[0].id
  target                = local.service_attachment_uris[var.region]
  network               = data.google_compute_network.network[0].id
}

# DNS Management
resource "google_dns_record_set" "psc_managed_zone_record" {
  count = var.disable_psc ? 0 : 1

  project = var.project_id

  name = "*.${google_dns_managed_zone.psc_managed_zone[0].dns_name}"
  type = "A"

  managed_zone = google_dns_managed_zone.psc_managed_zone[0].name

  rrdatas = [data.google_compute_address.psc_address[0].address]
}

resource "google_dns_managed_zone" "psc_managed_zone" {
  count = var.disable_psc ? 0 : 1

  name        = var.project_name == null ? "${var.project_id}-private-zone" : "${var.project_name}-private-zone"
  project     = var.project_id
  dns_name    = local.elastic_private_dns[var.region]
  description = "DNS Zone for Elastic Private Service Connect"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.network[0].self_link
    }
  }
}
