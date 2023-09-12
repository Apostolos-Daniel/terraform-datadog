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

variable "emails" {
  type    = list(any)
  default = ["dev@toli.io", "datadog@toli.io"]
}

data "datadog_user" "users" {
  for_each = toset(var.emails)
  filter   = each.key
}

# Create new team_membership resource
# https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
resource "datadog_team_membership" "foo" {
  for_each   = data.datadog_user.users
  team_id    = datadog_team.foo.id
  user_id    = each.value.id
  role       = "admin"
  depends_on = [data.datadog_user.users]
}
