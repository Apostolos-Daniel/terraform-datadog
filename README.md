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


## Adding an existing resource via terraform

You will probably get into a scenario where you create an existing Datadog resource (that was created via the UI). This begs some quesitons:

1. What happens to the existing resource?
2. What happens if you have created the resource differently?
3. What happens if someone changes the resource in the Datadog UI?
4. What happens if you decide you don't want to create it via terraform anymore?

### Example: creating a user

You might decide to create a Datadog user via terraform:

```
resource "datadog_user" "dev_toli" {
  email = "dev@toli.io"
}
```

This will apply the following change:

```
Terraform used the selected providers to generate the
following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # datadog_user.dev_toli will be created
  + resource "datadog_user" "dev_toli" {
      + disabled             = false
      + email                = "dev@toli.io"
      + id                   = (known after apply)
      + send_user_invitation = true
      + user_invitation_id   = (known after apply)
      + verified             = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

In this scenario, the user will be created with the properties configured which doesn't provide a role to the user. Previously the user `dev@toli.io` had the `Standard User` role. 

To fix this you have two options:

1. Add a role to the user
2. Manage the user by UI only again

For the first option, you can add this terraform:

```
# Get the standard user role
data "datadog_role" "datadog_standard_role" {
  filter = "Datadog Standard Role"
}

# Set the user's role to Standard and give them a name
resource "datadog_user" "dev_toli" {
  email = "dev@toli.io"
  name = "Toli"
  roles = [ data.datadog_role.datadog_standard_role ]
  send_user_invitation = true
}
```

This will change the newly created Datadog user to include permissions and a name:

```
source actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # datadog_user.dev_toli will be updated in-place
  ~ resource "datadog_user" "dev_toli" {
        id                   = "de181949-51c1-11ee-b1a2-96e56d99f005"
      + name                 = "Toli"
      ~ roles                = [
          + "439c8554-51af-11ee-9bc3-da7ad0900005",
        ]
        # (5 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

```

For the second option, you have to remove the user from terraform. This will remove the user from Datadog entirely. Commented out rather than deleting to demonstrate it is removed.

```
# This user is managed via Datadog UI
# resource "datadog_user" "accounts_toli" {
#   email = "accounts@toli.io"
#   name = "Toli"
#   roles = [ data.datadog_role.datadog_standard_role.id ]
#   send_user_invitation = true
# }
```

```
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # datadog_user.accounts_toli will be destroyed
  # (because datadog_user.accounts_toli is not in configuration)
  - resource "datadog_user" "accounts_toli" {
      - disabled             = false -> null
      - email                = "accounts@toli.io" -> null
      - id                   = "65b08a1a-528a-11ee-93e2-42fcbf8d4523" -> null
      - name                 = "Toli" -> null
      - roles                = [
          - "439c8554-51af-11ee-9bc3-da7ad0900005",
        ] -> null
      - send_user_invitation = true -> null
      - user_invitation_id   = "d55e3d4e-528a-11ee-b3de-da7ad0900005" -> null
      - verified             = true -> null
    }

```

This doesn't actually delete the user but it "disables" it. Tick on the Disabled Status to include it in the list, edit the user (in this case `accounts@toli.io`), and set to `Active`. Make sure that you select the appropriate Default Login Method, if you need to.