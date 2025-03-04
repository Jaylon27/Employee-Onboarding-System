# Resource block for Azure App Service Plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.prefix}-appserviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }

  kind = "Linux"
  reserved = true
}

# Resource block for Azure App Service
resource "azurerm_app_service" "app_service" {
  name                = "${var.prefix}-app-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  identity {
    type = "SystemAssigned"
  }

   site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.registry.login_server}/employeeonboardingsystem:latest"
  }

  app_settings = {
    UseOnlyInMemoryDatabase      = "true"
    ASPNETCORE_ENVIRONMENT       = "Docker"
    ASPNETCORE_HTTP_PORTS        = "80"
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
  }

}

# Resource block for Azure Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "${var.prefix}-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Resource block for Azure Container Registry
resource "azurerm_container_registry" "registry" {
  name                = "${var.prefix}registry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

# Assign role to Managed Identity for SQL Database access
resource "azurerm_role_assignment" "db_contributor" {
  principal_id         = azurerm_app_service.app_service.identity[0].principal_id
  role_definition_name = "SQL DB Contributor"
  scope                = azurerm_mssql_database.db.id
}

# Assign role to Managed Identity for Azure Container Registry pull access
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_app_service.app_service.identity[0].principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.registry.id
  skip_service_principal_aad_check = true
}

# Resource block for Azure App Service Virtual Network Integration
resource "azurerm_app_service_virtual_network_swift_connection" "app_service_vnet_integration" {
  app_service_id = azurerm_app_service.app_service.id
  subnet_id      = azurerm_subnet.app_subnet.id
}


