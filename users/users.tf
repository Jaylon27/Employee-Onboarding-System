# Provider configuration
provider "azuread" {}

# Retrieve Azure AD domain information
data "azuread_domains" "default" {
  only_initial = true
}

# Local variables
locals {
  # Get the primary domain name
  domain_name = data.azuread_domains.default.domains[0].domain_name

  # Decode the CSV file into a map
  users = csvdecode(file("${path.module}/users.csv"))
}

# Create Azure AD Users
resource "azuread_user" "users" {
  for_each = { for user in local.users : "${user.first_name}.${user.last_name}" => user }

  user_principal_name = format(
    "%s%s@%s",
    substr(lower(each.value.first_name), 0, 1),
    lower(each.value.last_name),
    local.domain_name
  )

  display_name           = "${each.value.first_name} ${each.value.last_name}"
  password               = format("Password%s!", length(each.value.first_name)) # Simplified password logic
  force_password_change  = true
  department             = each.value.department
  job_title              = each.value.job_title
}
