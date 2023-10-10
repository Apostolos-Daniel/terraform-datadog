terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

resource "datadog_api_key" "example" {
  name = "example-api-key-created-by-terraform"
}