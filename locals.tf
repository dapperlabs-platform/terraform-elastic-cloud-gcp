locals {
  # List of Private DNS addresses provided by Elastic: https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-psc.html
  # If adding a region, make sure to add the `.` at the end
  elastic_private_dns = {
    "asia-east1"              = "psc.asia-east1.gcp.elastic-cloud.com."
    "asia-northeast1"         = "psc.asia-northeast1.gcp.cloud.es.io."
    "asia-northeast3"         = "psc.asia-northeast3.gcp.elastic-cloud.com."
    "asia-south1"             = "psc.asia-south1.gcp.elastic-cloud.com."
    "asia-southeast1"         = "psc.asia-southeast1.gcp.elastic-cloud.com."
    "australia-southeast1"    = "psc.australia-southeast1.gcp.elastic-cloud.com."
    "europe-north1"           = "psc.europe-north1.gcp.elastic-cloud.com."
    "europe-west1"            = "psc.europe-west1.gcp.cloud.es.io."
    "europe-west2"            = "psc.europe-west2.gcp.elastic-cloud.com."
    "europe-west3"            = "psc.europe-west3.gcp.cloud.es.io."
    "europe-west4"            = "psc.europe-west4.gcp.elastic-cloud.com."
    "northamerica-northeast1" = "psc.northamerica-northeast.gcp.elastic-cloud.com."
    "southamerica-east1"      = "psc.southamerica-east1.gcp.elastic-cloud.com."
    "us-central1"             = "psc.us-central1.gcp.cloud.es.io."
    "us-east1"                = "psc.us-east1.gcp.elastic-cloud.com."
    "us-east4"                = "psc.us-east4.gcp.elastic-cloud.com."
    "us-west1"                = "psc.us-west1.gcp.cloud.es.io."
  }

  # Dapper VPN IPs for use in Traffic Filtering rules
  vpn_ips = {
    for idx, ip in nonsensitive(split(",", try(data.google_secret_manager_secret_version.vpn_ips_latest.secret_data, ""))) :
    "VPN IP ${idx}" => "${ip}/32"
  }
}
