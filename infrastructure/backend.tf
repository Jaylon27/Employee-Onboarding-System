terraform {
  backend "azurerm" {
    resource_group_name  = "employeeonboardingsystem-resources"
    storage_account_name = "employeesstorageaccount1"
    container_name       = "prod-tfstate"
    key                  = "prod.terraform.tfstate"
  }
}