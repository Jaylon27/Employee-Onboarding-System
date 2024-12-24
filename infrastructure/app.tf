resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${prefix}-appserviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "${prefix}-app-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_container_registry" "registry" {

  name                = "${prefix}registry" 
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  sku                 = "Standard"
  admin_enabled       = true 
}

# Assign db_datareader role to Managed Identity for SQL Database access
resource "azurerm_role_assignment" "db_datareader" {
  principal_id        = azurerm_app_service.app_service.identity[0].principal_id
  role_definition_name = "db_datareader"  
  scope               = azurerm_sql_database.db.id
}

# Assign db_datawriter role to Managed Identity for SQL Database access
resource "azurerm_role_assignment" "db_datawriter" {
  principal_id        = azurerm_app_service.app_service.identity[0].principal_id
  role_definition_name = "db_datawriter"  
  scope               = azurerm_sql_database.db.id
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_app_service.app_service.identity[0].principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.registry.id
  skip_service_principal_aad_check = true
}

resource "azurerm_app_service_virtual_network_swift_connection" "app_service_vnet_integration" {
  app_service_id = azurerm_app_service.app_service.id
  subnet_id      = azurerm_subnet.app_subnet.id
}

