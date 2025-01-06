# IT Group
resource "azuread_group" "information_tech" {
  display_name    = "Information Technology"
  mail_enabled    = false 
  security_enabled = true   

}

# Associate IT associates with the Information Technology group
resource "azuread_group_member" "information_tech_associates" {
  for_each = { for u in azuread_user.users: u.mail_nickname => u if u.department == "Information Technology" }


  group_object_id  = azuread_group.information_tech.id
  member_object_id = each.value.id

}

# IT Managers Group
resource "azuread_group" "information_tech_managers" {
  display_name    = "Information Technology Managers"
  mail_enabled    = false 
  security_enabled = true   

}

# Associate IT managers with the Information Technology group
resource "azuread_group_member" "information_tech_managers" {
  for_each = { for u in azuread_user.users: u.mail_nickname => u if u.department == "Information Technology Managers" }

  group_object_id  = azuread_group.information_tech_managers.id
  member_object_id = each.value.id
}

# Human Resources Group
resource "azuread_group" "human_resources" {
  display_name    = "Human Resources"
  mail_enabled    = false  
  security_enabled = true   

}

# Associate HR users with the Human Resources group
resource "azuread_group_member" "human_resources_associates" {
  for_each = { for u in azuread_user.users: u.mail_nickname => u if u.department == "Human Resources" }


  group_object_id  = azuread_group.human_resources.id
  member_object_id = each.value.id

}

# Human Resources Managers Group
resource "azuread_group" "human_resources_managers" {
  display_name    = "Human Resources Managers"
  mail_enabled    = false  
  security_enabled = true   

}

# Associate HR managers with the Human Resources group
resource "azuread_group_member" "human_resources_managers" {
for_each = { for u in azuread_user.users: u.mail_nickname => u if u.department == "Human Resources Managers" }


  group_object_id  = azuread_group.human_resources_managers.id
  member_object_id = each.value.id
}