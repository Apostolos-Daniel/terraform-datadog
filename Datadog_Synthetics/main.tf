
# Terraform 0.13+ uses the Terraform Registry:
terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

# Get the synthetics locations
data "datadog_synthetics_locations" "test" {
}

locals {
  synthetic_location_ireland = [for key, name in data.datadog_synthetics_locations.test.locations : key if name == "Ireland (AWS)"]
  // this converts a map of key/value pairs of tags, e.g. key=created_by, value=terraform 
  // to a list of string key/value pairs with format key:value, e.g. 'created_by:terraform'
  tags_list = [for key, value in var.tags : "${key}:${value}"]
}

# Get the team
data "datadog_team" "example_team" {
  team_id = "e1dd94ac-53fc-11ee-a877-da7ad0900005" // "Example Team" https://app.datadoghq.eu/organization-settings/teams?team_id=bd9527ea-528f-11ee-b38e-da7ad0900005
}


# Example Usage (Synthetics Multistep API test)
# Create a new Datadog Synthetics Multistep API test
resource "datadog_synthetics_test" "test_multi_step" {
  name      = "Multistep API test"
  type      = "api"
  subtype   = "multi"
  status    = "live"
  message   = <<EOT
  Notify @qa
  
  line 2 Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum 

  line 3 Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum
EOT
  locations = local.synthetic_location_ireland
  tags      = concat(["foo:bar", "foo", "env:test", "team:${data.datadog_team.example_team.handle}"], local.tags_list)

  api_step {
    name    = "An API test on example.org"
    subtype = "http"

    assertion {
      type     = "statusCode"
      operator = "is"
      target   = "200"
    }

    assertion {
      type     = "body"
      operator = "contains"
      target   = " <title>Example Domain</title>"
    }

    request_definition {
      method = "GET"
      url    = "https://example.org"
    }

    request_headers = {
      Content-Type   = "application/json"
      Authentication = "Token: 1234566789"
    }
  }

  api_step {
    name    = "An API test on example.org"
    subtype = "http"

    assertion {
      type     = "statusCode"
      operator = "is"
      target   = "200"
    }

    assertion {
      type     = "body"
      operator = "contains"
      target   = " <title>Example Domain</title>"
    }

    request_definition {
      method = "GET"
      url    = "http://example.org"
    }
  }

  options_list {
    tick_every         = 900
    accept_self_signed = true
    monitor_name       = "Synthetic monitor"
    monitor_priority   = 1
    retry {
      count    = 2
      interval = 300
    }
    monitor_options {
      renotify_interval = 120
    }
  }
}
