# Atlantis Public IPs for Traffic Filter Rule
# NOTE: this is for when Atlantis is being run on Gen 2 infra. This will need to be changed when we transition Atlantis to Gen 3
data "google_compute_address" "atlantis_ips" {
  count = 14

  name    = "us-east4-production-2%{if count.index == 0}%{else}-${count.index + 1}%{endif}"
  project = "dapper-ops"
  region  = "us-east4"
}


# The VPC network
data "google_compute_network" "network" {
  project = var.project_id
  name    = "gke-application-cluster-vpc"
}

# We need this because the resource doesn't automatically export the IP address for some reason
data "google_compute_address" "psc_address" {
  depends_on = [google_compute_address.psc_address]

  name    = var.project_name == null ? "${var.project_id}-psc-address" : "${var.project_name}-psc-address"
  region  = var.region
  project = var.project_id
}

# Private Service connect IP Address
resource "google_compute_address" "psc_address" {
  name         = var.project_name == null ? "${var.project_id}-psc-address" : "${var.project_name}-psc-address"
  region       = var.region
  address_type = "INTERNAL"
  project      = var.project_id
  subnetwork   = data.google_compute_network.network.subnetworks_self_links[0]
}

# DNS Management
resource "google_dns_record_set" "psc_managed_zone_record" {
  project = var.project_id

  name = "*.${google_dns_managed_zone.psc_managed_zone.dns_name}"
  type = "A"

  managed_zone = google_dns_managed_zone.psc_managed_zone.name

  rrdatas = [data.google_compute_address.psc_address.address]
}

resource "google_dns_managed_zone" "psc_managed_zone" {
  provider = google-beta

  name        = var.project_name == null ? "${var.project_id}-private-zone" : "${var.project_name}-private-zone"
  project     = var.project_id
  dns_name    = local.elastic_private_dns[var.region]
  description = "DNS Zone for Elastic Private Service Connect"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.network.self_link
    }
  }
}
