locals {
  # List of Private DNS addresses provided by Elastic: https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-html
  # If adding a region, make sure to add the `.` at the end and to remove `psc` from the front.
  elastic_private_dns = {
    "asia-east1"              = "asia-east1.gcp.elastic-cloud.com."
    "asia-northeast1"         = "asia-northeast1.gcp.cloud.es.io."
    "asia-northeast3"         = "asia-northeast3.gcp.elastic-cloud.com."
    "asia-south1"             = "asia-south1.gcp.elastic-cloud.com."
    "asia-southeast1"         = "asia-southeast1.gcp.elastic-cloud.com."
    "australia-southeast1"    = "australia-southeast1.gcp.elastic-cloud.com."
    "europe-north1"           = "europe-north1.gcp.elastic-cloud.com."
    "europe-west1"            = "europe-west1.gcp.cloud.es.io."
    "europe-west2"            = "europe-west2.gcp.elastic-cloud.com."
    "europe-west3"            = "europe-west3.gcp.cloud.es.io."
    "europe-west4"            = "europe-west4.gcp.elastic-cloud.com."
    "northamerica-northeast1" = "northamerica-northeast.gcp.elastic-cloud.com."
    "southamerica-east1"      = "southamerica-east1.gcp.elastic-cloud.com."
    "us-central1"             = "us-central1.gcp.cloud.es.io."
    "us-east1"                = "us-east1.gcp.elastic-cloud.com."
    "us-east4"                = "us-east4.gcp.elastic-cloud.com."
    "us-west1"                = "us-west1.gcp.cloud.es.io."
  }
}
