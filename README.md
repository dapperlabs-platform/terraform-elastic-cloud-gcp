# Elasticsearch

## What does this do?

Creates an Elastic Cloud Deployment with traffic filter rules to only allow traffic from Dapper VPNs and the VPC of the accompanying GCP project.

## How to provision this module?

You can always refer to the [Notion doc](https://www.notion.so/dapperlabs/Deploy-an-Elastic-Cloud-Deployment-7185333a542341ba9faf18da5b9a97c1) for more info.

1. Add the module with every variable you want to set except for the `private_service_connect_id` variable and make/merge a PR with these settings.
    * If you are deploying to a Gen 2 project, be sure to set the variable `project_name`.
    * If you want to make the deployment publicly accessible, set `make_public` to true.
    * The variable vpn\_ips can be set to `local.vpn_ips` in Gen 3 projects and `local.perimeter_81_ips` in Gen 2 projects.
2. Follow the steps [here](https://cloud.google.com/vpc/docs/configure-private-service-connect-services#create-endpoint) to create a Private Service Connect endpoint in the proper GCP project.
    * For `target` please select `Published Service` from the radio buttons
    * For `target service` use the corresponding URI from [this](https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-psc.html#ec-private-service-connect-uris) page depending on the region of the project.
    * For `endpoint name` please use the naming convention `<GCP_PROJECT_NAME>-psc`. ex: `dl-sre-staging-psc`
    * For `subnetwork` please select `gke` from the dropdown (will probably be the only option)
    * For `IP address` select `<GCP_PROJECT_NAME>-psc-address` from the dropdown (will probably be the only option)
    * For `service directory` please do NOT choose a namespace as this will place the PSC in the default namespace (which is the desired bahavior)
3. Once the private service connect is created, grab the PSC Connection ID and update the `private_service_connect_id` variable in the module and raise a second PR with these updates.

### For the End User
If the deployment is not publicly accessible, then anonymous access (with limited permissions) is enabled and all users will have to do to access the elasticsearch cluster is to curl the endpoint, which is conveniently provided as an output variable. If they have need of greater permissions, or are trying to access a publicly available deployment, then they will need to use the username/password of the cluster to gain access. These are available as outputs as well, however, the password is marked as sensitive and end users will not be able to directly access it.

### Potential Breaking changes
Currently, the provider (and any user who will define Elasticstack resources in Terraform), need Atlantis to be able to communicate with the Elastic Cloud Deployment. The current set up of this module assumes Atlantis is running on the Gen 2 production cluster. If Atlantis is moved to Gen 3 architecture, this module will need to update the `atlantis_ips` data source to reflect the current list of public IPs that Atlantis can use.

### Usage Examples

#### Regular Use
```hcl
module "elasticsearch" {
  source     = "git@github.com:dapperlabs/terraform-modules.git//elasticsearch?ref=<VERSION>"
  project_id = module.project.project_id
  region     = var.default_region

  // private_service_connect_id = "<PRIVATE_SERVICE_CONNECT_ID>" # Uncomment this after manually creating Private Service Connect
}
```

#### Gen 2 Use Example
```hcl
module "elasticsearch" {
  source       = "git@github.com:dapperlabs/terraform-modules.git//elasticsearch?ref=<VERSION>"
  project_id   = module.project.project_id
  project_name = "nba-staging"
  region       = var.default_region

  // private_service_connect_id = "<PRIVATE_SERVICE_CONNECT_ID>" # Uncomment this after manually creating Private Service Connect
}
```

#### Custom Elastic Deployment Needs
```hcl
module "elasticsearch" {
  source     = "git@github.com:dapperlabs/terraform-modules.git//elasticsearch?ref=<VERSION>"
  project_id = module.project.project_id
  region     = var.default_region

	elastic_topology = [
    {
      id         = "hot_content"
      size       = "16g"
      zone_count = 6
      autoscaling = {
        max_size = "128g"
      }
    },
		{
      id         = "cold"
      size       = "1g"
      zone_count = 2
      autoscaling = {
        max_size = "16g"
      }
    }
  ]

  // private_service_connect_id = "<PRIVATE_SERVICE_CONNECT_ID>" # Uncomment this after manually creating Private Service Connect
}
```

## Updating this module
`make` updates the `README.md` file based on Terraform changes.

## Requires

1. `terraform` [Download](https://www.terraform.io/downloads.html) [Brew](https://formulae.brew.sh/formula/terraform)
2. `terraform-docs` to update the README. [Download](https://github.com/terraform-docs/terraform-docs) [Brew](https://formulae.brew.sh/formula/terraform-docs)
3. `make` to update the README. [Download](https://www.gnu.org/software/make/)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ec"></a> [ec](#requirement\_ec) | ~> 0.4.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ec"></a> [ec](#provider\_ec) | ~> 0.4.0 |
| <a name="provider_elasticstack"></a> [elasticstack](#provider\_elasticstack) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.0.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | ~> 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ec_deployment.elastic_cloud_deployment](https://registry.terraform.io/providers/elastic/ec/latest/docs/resources/deployment) | resource |
| [ec_deployment_traffic_filter.filter_atlantis_ips](https://registry.terraform.io/providers/elastic/ec/latest/docs/resources/deployment_traffic_filter) | resource |
| [ec_deployment_traffic_filter.filter_gcp_psc](https://registry.terraform.io/providers/elastic/ec/latest/docs/resources/deployment_traffic_filter) | resource |
| [ec_deployment_traffic_filter.filter_vpn_ips](https://registry.terraform.io/providers/elastic/ec/latest/docs/resources/deployment_traffic_filter) | resource |
| [elasticstack_elasticsearch_security_role.anonymous_role](https://registry.terraform.io/providers/hashicorp/elasticstack/latest/docs/resources/elasticsearch_security_role) | resource |
| [google-beta_google_dns_managed_zone.psc_managed_zone](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dns_managed_zone) | resource |
| [google_compute_address.psc_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_dns_record_set.psc_managed_zone_record](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_compute_address.atlantis_ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address) | data source |
| [google_compute_address.psc_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address) | data source |
| [google_compute_network.network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_elastic_deployment_template_name"></a> [elastic\_deployment\_template\_name](#input\_elastic\_deployment\_template\_name) | The instance type to use in the deployment. Go to https://www.elastic.co/guide/en/cloud/current/ec-regions-templates-instances.html for a list of options. | `string` | `"gcp-general-purpose"` | no |
| <a name="input_elastic_topology"></a> [elastic\_topology](#input\_elastic\_topology) | Configuration settings list for desired Elasticsearch topologies. See https://registry.terraform.io/providers/elastic/ec/latest/docs/resources/ec_deployment#topology for definitions of topology settings. | <pre>list(object({<br>    id         = string<br>    size       = string<br>    zone_count = string<br>    autoscaling = object({<br>      max_size = string<br>    })<br>  }))</pre> | <pre>[<br>  {<br>    "autoscaling": {<br>      "max_size": "64g"<br>    },<br>    "id": "hot_content",<br>    "size": "4g",<br>    "zone_count": 3<br>  }<br>]</pre> | no |
| <a name="input_elastic_version"></a> [elastic\_version](#input\_elastic\_version) | The version of Elasticsearch to use | `string` | `"8.1.2"` | no |
| <a name="input_kibana_topology"></a> [kibana\_topology](#input\_kibana\_topology) | Configuration settings list for desired Kibana topologies. See https://registry.terraform.io/providers/elastic/ec/latest/docs/resources/ec_deployment#topology for definitions of topology settings. | <pre>list(object({<br>    size       = string<br>    zone_count = string<br>  }))</pre> | `[]` | no |
| <a name="input_make_public"></a> [make\_public](#input\_make\_public) | Boolean that will expose the Elastic Cloud deployments to the public internet. You will still need a username/password to connect | `bool` | `false` | no |
| <a name="input_private_service_connect_id"></a> [private\_service\_connect\_id](#input\_private\_service\_connect\_id) | The private service connect id, add this after manually creating the private service connect in the GCP console | `string` | `"0"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project id. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | A name variable used to name the resources. Should only be set if deploying to a Gen 2 project | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the deployment | `string` | `"us-west1"` | no |
| <a name="input_vpn_ips"></a> [vpn\_ips](#input\_vpn\_ips) | Map of VPN IPs to allowlist for access to Elastic Cloud deployment. If make\_public is false, this variable must be set. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elasticsearch_https_endpoint"></a> [elasticsearch\_https\_endpoint](#output\_elasticsearch\_https\_endpoint) | n/a |
| <a name="output_elasticsearch_password"></a> [elasticsearch\_password](#output\_elasticsearch\_password) | n/a |
| <a name="output_elasticsearch_user"></a> [elasticsearch\_user](#output\_elasticsearch\_user) | n/a |
| <a name="output_kibana_endpoint"></a> [kibana\_endpoint](#output\_kibana\_endpoint) | n/a |
