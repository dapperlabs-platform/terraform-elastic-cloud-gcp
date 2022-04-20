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

variable "make_public" {
  description = "Boolean that will expose the Elastic Cloud deployments to the public internet. You will still need a username/password to connect"
  type        = bool
  default     = false
}

variable "allowed_ips" {
  description = "Map of IPs to allowlist for access to Elastic Cloud deployment. If make_public is false, this variable must be set or you will not be able to access the deployment."
  type        = map(string)
  default     = null
}

variable "vpc_name" {
  description = "The name of the VPC network of the GKE cluster we want to allow communication from"
  type        = string
  default     = "gke-application-cluster-vpc"
}

variable "enable_anonymous_access" {
  description = "This will enable users to access the cluster anonymously (i.e. without username/password). Will only be enabled for private deployments."
  type        = bool
  default     = false
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

variable "kibana_topology" {
  description = "Configuration settings list for desired Kibana topologies. See https://registry.terraform.io/providers/elastic/ec/latest/docs/resources/ec_deployment#topology for definitions of topology settings."
  type = list(object({
    size       = string
    zone_count = string
  }))
  default = []
}

variable "disable_psc" {
  description = "This will disable the creation of the networking resources required to provide authentication to Elastic Cloud via GCP Private Service connect"
  type        = bool
  default     = false
}

variable "request_id" {
  description = "This variable is sometimes needed when the Elastic API encounters an error. Only set this if told to by the output of a Terraform apply"
  type        = string
  default     = null
}
