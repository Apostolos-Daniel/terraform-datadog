# terraform-datadog

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog_monitor_config_policy"></a> [datadog\_monitor\_config\_policy](#module\_datadog\_monitor\_config\_policy) | ./modules/datadog_monitor_config_policy | n/a |
| <a name="module_datadog_synthetics"></a> [datadog\_synthetics](#module\_datadog\_synthetics) | ./datadog_synthetics | n/a |
| <a name="module_datadog_teams"></a> [datadog\_teams](#module\_datadog\_teams) | ./datadog_teams | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | Datadog API Key | `string` | n/a | yes |
| <a name="input_datadog_api_url"></a> [datadog\_api\_url](#input\_datadog\_api\_url) | Datadog API URL | `string` | `"https://app.datadoghq.eu"` | no |
| <a name="input_datadog_app_key"></a> [datadog\_app\_key](#input\_datadog\_app\_key) | Datadog Application Key | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags for Datadog resources | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
