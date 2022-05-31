locals {
  # List of Private DNS addresses provided by Elastic: https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-psc.html#ec-private-service-connect-uris
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
  # List of Service Attachment URIs provided by Elastic: https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-psc.html#ec-private-service-connect-uris
  service_attachment_uris = {
    "asia-east1"              = "projects/cloud-production-168820/regions/asia-east1/serviceAttachments/proxy-psc-production-asia-east1-v1-attachment"
    "asia-northeast1"         = "projects/cloud-production-168820/regions/asia-northeast1/serviceAttachments/proxy-psc-production-asia-northeast1-v1-attachment"
    "asia-northeast3"         = "projects/cloud-production-168820/regions/asia-northeast3/serviceAttachments/proxy-psc-production-asia-northeast3-v1-attachment"
    "asia-south1"             = "projects/cloud-production-168820/regions/asia-south1/serviceAttachments/proxy-psc-production-asia-south1-v1-attachment"
    "asia-southeast1"         = "projects/cloud-production-168820/regions/asia-southeast1/serviceAttachments/proxy-psc-production-asia-southeast1-v1-attachment"
    "australia-southeast1"    = "projects/cloud-production-168820/regions/australia-southeast1/serviceAttachments/proxy-psc-production-australia-southeast1-v1-attachment"
    "europe-north1"           = "projects/cloud-production-168820/regions/europe-north1/serviceAttachments/proxy-psc-production-europe-north1-v1-attachment"
    "europe-west1"            = "projects/cloud-production-168820/regions/europe-west1/serviceAttachments/proxy-psc-production-europe-west1-v1-attachment"
    "europe-west2"            = "projects/cloud-production-168820/regions/europe-west2/serviceAttachments/proxy-psc-production-europe-west2-v1-attachment"
    "europe-west3"            = "projects/cloud-production-168820/regions/europe-west3/serviceAttachments/proxy-psc-production-europe-west3-v1-attachment"
    "europe-west4"            = "projects/cloud-production-168820/regions/europe-west4/serviceAttachments/proxy-psc-production-europe-west4-v1-attachment"
    "northamerica-northeast1" = "projects/cloud-production-168820/regions/northamerica-northeast1/serviceAttachments/proxy-psc-production-northamerica-northeast1-v1-attachment"
    "southamerica-east1"      = "projects/cloud-production-168820/regions/southamerica-east1/serviceAttachments/proxy-psc-production-southamerica-east1-v1-attachment"
    "us-central1"             = "projects/cloud-production-168820/regions/us-central1/serviceAttachments/proxy-psc-production-us-central1-v1-attachment"
    "us-east1"                = "projects/cloud-production-168820/regions/us-east1/serviceAttachments/proxy-psc-production-us-east1-v1-attachment"
    "us-east4"                = "projects/cloud-production-168820/regions/us-east4/serviceAttachments/proxy-psc-production-us-east4-v1-attachment"
    "us-west1"                = "projects/cloud-production-168820/regions/us-west1/serviceAttachments/proxy-psc-production-us-west1-v1-attachment"
  }
}
