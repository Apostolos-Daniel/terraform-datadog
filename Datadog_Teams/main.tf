terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
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

# Get the standard user role
data "datadog_role" "datadog_standard_role" {
  filter = "Datadog Standard Role"
}

# Set the user's role to Standard and give them a name
resource "datadog_user" "dev_toli" {
  email = "dev@toli.io"
  name = "Toli"
  roles = [ data.datadog_role.datadog_standard_role.id ]
  send_user_invitation = true
}

# This user is managed via Datadog UI
# resource "datadog_user" "accounts_toli" {
#   email = "accounts@toli.io"
#   name = "Toli"
#   roles = [ data.datadog_role.datadog_standard_role.id ]
#   send_user_invitation = true
# }


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
