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

resource "datadog_team" "foo" {
  description = "Team description"
  handle      = "example-team"
  name        = "Example Team"
}

data "datadog_user" "dev_toli" {
  filter = "dev@toli.io"
}

# Create new team_membership resource
resource "datadog_team_membership" "foo" {
  team_id = datadog_team.foo.id
  user_id = data.datadog_user.dev_toli.id
  role    = "admin"
}