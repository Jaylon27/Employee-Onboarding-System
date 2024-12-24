terraform {
  backend "azurerm" {
    resource_group_name  = "managedidsandgov-resources"
    storage_account_name = "idsandgovstorage"
    container_name       = "prod-tfstate"
    key                  = "prod.terraform.tfstate"
  }
}