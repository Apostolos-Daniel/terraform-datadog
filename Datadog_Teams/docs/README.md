# Datadog_Teams

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 3.30.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_team.example_team](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/team) | resource |
| [datadog_team_membership.example_team_membership](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/team_membership) | resource |
| [datadog_user.dev_toli](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/user) | resource |
| [datadog_role.datadog_standard_role](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/data-sources/role) | data source |
| [datadog_user.users](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_emails"></a> [emails](#input\_emails) | n/a | `list(any)` | <pre>[<br>  "dev@toli.io",<br>  "datadog@toli.io"<br>]</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
