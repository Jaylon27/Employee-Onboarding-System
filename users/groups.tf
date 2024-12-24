# Local variables
locals {
  # Filter users by department
  it_users = {
    for k, u in azuread_user.users :
    k => u if u.department == "IT (Information Technology)"
  }

  hr_users = {
    for k, u in azuread_user.users :
    k => u if u.department == "Human Resources"
  }

  managers = {
    for k, u in azuread_user.users :
    k => u if u.job_title == "Manager"
  }
}

# IT Group
resource "azuread_group" "information_tech" {
  display_name     = "IT (Information Technology) Department"
  security_enabled = true
}

resource "azuread_group_member" "information_tech_associates" {
  for_each = local.it_users

  group_object_id  = azuread_group.information_tech.id
  member_object_id = each.value.id
}

# Human Resources Group
resource "azuread_group" "human_resources" {
  display_name     = "Human Resources Department"
  security_enabled = true
}

resource "azuread_group_member" "human_resources_associates" {
  for_each = local.hr_users

  group_object_id  = azuread_group.human_resources.id
  member_object_id = each.value.id
}

# Managers Group
resource "azuread_group" "managers" {
  display_name     = "Managers"
  security_enabled = true
}

resource "azuread_group_member" "managers" {
  for_each = local.managers

  group_object_id  = azuread_group.managers.id
  member_object_id = each.value.id
}
