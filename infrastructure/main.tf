# Resource Group to contain all resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-resources"
  location = var.location
}





