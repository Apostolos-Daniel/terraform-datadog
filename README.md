# terraform-datadog
An example usage of Datadog terraform provider, following the following documents [this guide](https://developer.hashicorp.com/terraform/tutorials/use-case/datadog-provider).


1. Sign up for a Datadog trial
2. [Install an agent](https://app.datadoghq.eu/signup/agent) - Datadog requires an agent to active even a trial account. You will most likely not be using this agent at all. 
3. You will need three environment variables, and set them as your environment variables

> export TF_VAR_datadog_api_url=<"https://app.datadoghq.eu">
> export TF_VAR_datadog_app_key=<create one here: https://app.datadoghq.eu/personal-settings/application-keys>
> export TF_VAR_datadog_api_key=<grab the default one created by Datadog for you here: https://app.datadoghq.eu/organization-settings/api-keys>


5. Run `touch main.tf` and include:

```
# Terraform 0.13+ uses the Terraform Registry:

terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}
```

4. You will need to create the variables you will use in [variables.tf](variables.tf) and then set them as part of the datadog module configuration.

Terraform uses the "TF_VAR_" naming convention for environment variables to read the values of the environment variables.


```
# Configure the Datadog provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}
```

5. To create an example resource, we can use the Datadog Teams provider:

```
resource "datadog_team" "foo" {
  description = "Team description"
  handle      = "example-team"
  name        = "Example Team"
}
```

6. Run `terraform init`. This will "initialize the backend". This creates a lock file called `.terraform.lock.hcl`. I *think* this just uses the local directory as a backend.

7. Run `terraform validate` - this should tell you "Success! The configuration is valid.". This rarely fails unless there is a syntax issue

8. Run `terraform plan` - this will tell you what changes will be planned to be applied. This is the most useful command for the feedback loop

8. To actually apply the changes run `terraform apply`

This actually applies the changes to your Datadog account, you should have [a team](https://app.datadoghq.eu/organization-settings/teams?team_id=15196222-51c0-11ee-998b-da7ad0900005) in Datadog 