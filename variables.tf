variable "datadog_api_key" {
  type        = string
  description = "Datadog API Key"
}

variable "datadog_app_key" {
  type        = string
  description = "Datadog Application Key"
}

variable "datadog_api_url" {
  type        = string
  description = "Datadog API URL"
  default     = "https://app.datadoghq.eu"
}

variable "default_tags" {
  type        = map(any)
  description = "Default tags for Datadog resources"
}