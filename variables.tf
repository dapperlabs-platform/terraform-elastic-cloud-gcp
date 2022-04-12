variable "project_id" {
  description = "The GCP project id."
  type        = string
}

variable "project_name" {
  description = "A name variable used to name the resources. Should only be set if deploying to a Gen 2 project"
  type        = string
  default     = null
}

variable "region" {
  description = "Region for the deployment"
  type        = string
  default     = "us-west1"
}

variable "elastic_version" {
  description = "The version of Elasticsearch to use"
  type        = string
  default     = "8.1.2"
}

variable "elastic_deployment_template_name" {
  description = "The instance type to use in the deployment. Go to https://www.elastic.co/guide/en/cloud/current/ec-regions-templates-instances.html for a list of options."
  type        = string
  default     = "gcp-general-purpose"
}

variable "private_service_connect_id" {
  description = "The private service connect id, add this after manually creating the private service connect in the GCP console"
  type        = string
  default     = "0"
}

variable "elastic_topology" {
  description = "Configuration settings list for desired Elasticsearch topologies. See https://registry.terraform.io/providers/elastic/ec/latest/docs/resources/ec_deployment#topology for definitions of topology settings."
  type = list(object({
    id         = string
    size       = string
    zone_count = string
    autoscaling = object({
      max_size = string
    })
  }))
  default = [
    {
      id         = "hot_content"
      size       = "4g"
      zone_count = 3
      autoscaling = {
        max_size = "64g"
      }
    }
  ]
}
