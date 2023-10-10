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

## Having multiple modules using the same provider

You can have multiple providers or multiple files for each provider. All provider configuration needs to be in the root directory for any child directories to receive them.

You can have the provider configuration in the root `main.tf` file:

```
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
```

Then you can move all the resource definition to a new direction, e.g. `datadog_teams`. This is a "module". It becomes a module when you reference it in the root file:

```
module "datadog_teams" {
  source = "./datadog_teams"
}
```

If you are moving the file and you have created the resources previously, terraform will update the resource name from:

```
  # datadog_user.dev_toli will be destroyed
  # (because datadog_user.dev_toli is not in configuration)
  - resource "datadog_user" "dev_toli" {
```

to 

```
  # module.datadog_teams.datadog_user.dev_toli will be created
  + resource "datadog_user" "dev_toli" {
```

See [Provider Configuration](configuration#provider-configuration-1) for details.

Every time you reference a new module, you need to run `terraform init` first.


## Using pre-commit hooks

You can use various useful git pre-commit hooks. 

I used [this repo](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) that includes a few useful terraform hooks.

- terraform_fmt: formats .tf files accordingly
- terraform_docs: auto-generates documentation
- terraform_validate: runs the `terraform validate` command, this is sensible to run before commiting

Run `pre-commit run -a` locally if you want to run the hooks without commiting.

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

## Creating a synthetic

You can use example synthetic resources on the [official terraform datadog provider documentation](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/synthetics_test#nested-schema-for-options_listmonitor_o) and then customise to suit your needs. 

### Multi-line message

You most likely will need a multi-line message in your monitor. The way to do this is by using the so-called "heredoc" style of string literal that terraform supports.

```
  message   = <<EOT
  Notify @qa
  
  line 2 Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum 

  line 3 Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum
EOT
```

## Terraform tips and tricks

You will end up typing `terraform` a lot so it's worth creating some alias. 

Aliases I use:

```
alias tf='terraform'
alias tfv='terraform validate'
alias tfi='terraform init'
alias tfp='terraform plan' 
alias tfm='terraform fmt -recursive'
```

See more [tips and trikcs](https://dev.to/svasylenko/terraform-cli-shortcuts-42gj)

## Setting default variables

If you want to set variables that have a default value, you will have to create them in the [variables.tf](./variables.tf) file in the root directory. E.g.:

```
variable "default_tags" {
  type        = map(any)
  description = "Default tags for Datadog resources"
}
```

Then if you want to give them a default value, the best approach is to use a separate `.tfvars` file, e.g. [tags.auto.tfvars](tags.auto.tfvars). This will be picked up automatically by terraform due to the naming convention of using the "auto" prefix in the file name (`auto.tfvars`). 

```
default_tags = {
  created_by = "terraform"
}
```

You now have a variable that you can reference in the root directory but to be able to reference it in a module, you have to "pass it through" in your module declaration:

```
module "datadog_synthetics" {
  source = "./datadog_synthetics"

  tags = var.default_tags
}
```

You can use a different variable name here as it's actually declared separately in the module itself, e.g. in [datadog_synthetics/main.tf](datadog_synthetics/main.tf):

```
variable "tags" {
  type        = map(any)
  description = "Default tags for synthetics"
}
```

Now, you can use this variable by referencing it as `var.tags`, e.g.:

```
locals {
  tags_list = [for key, value in var.tags : "${key}:${value}"]
}
```

Alternatively, you could consider extracting the variable definition in `main.tf` of the module into a `variables.tf` file, for better clarity of concerns. 

## Add tagging policies

You can add tagging policies to your Datadog account via terraform. This is useful if you want to enforce tagging policies on your Datadog account.

You can create a tagging policy via terraform:

```
mkdir modules
mkdir modules/datadog_monitor_config_policy
touch modules/datadog_monitor_config_policy/main.tf
terraform init
```

And add the following to `main.tf` via bash:

```
resource "datadog_monitor_config_policy" "test" {
  policy_type = "tag"
  tag_policy {
    tag_key          = "env"
    tag_key_required = false
    valid_tag_values = ["staging", "prod"]
  }
}
```