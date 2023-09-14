
# Terraform 0.13+ uses the Terraform Registry:

terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}


# Get the standard user role
data "datadog_team" "example_team" {
  filter_keyword = "Example team"
}

# Example Usage (Synthetics Multistep API test)
# Create a new Datadog Synthetics Multistep API test
resource "datadog_synthetics_test" "test_multi_step" {
  name      = "Multistep API test"
  type      = "api"
  subtype   = "multi"
  status    = "live"
  message   = "Notify @qa"
  locations = ["aws:eu-central-1"]
  tags      = ["foo:bar", "foo", "env:test", "team:example-team"]

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
