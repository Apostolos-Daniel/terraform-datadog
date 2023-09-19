# Terraform 0.13+ uses the Terraform Registry:

terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

# Configure the Datadog provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

module "datadog_teams" {
  source = "./datadog_teams"
}

module "datadog_synthetics" {
  source = "./datadog_synthetics"

  tags = var.default_tags
}


module "datadog_monitor_config_policy" {
  source = "./modules/datadog_monitor_config_policy"
}