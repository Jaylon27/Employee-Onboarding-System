// Azure SQL Server resource configuration
resource "azurerm_mssql_server" "server" {
  name                         = "${var.prefix}databaseforonboarding"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  version                      = "12.0"
}

// Azure SQL Database resource configuration
resource "azurerm_mssql_database" "db" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.server.id
}

// Azure Private Endpoint for the SQL Database
resource "azurerm_private_endpoint" "database_endpoint" {
  name                = "${var.prefix}private-endpoint-sql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.database_subnet.id

  // Configuration for the private service connection
  private_service_connection {
    name                           = "${var.prefix}private-serviceconnection"
    private_connection_resource_id = azurerm_mssql_server.server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
  
  // DNS zone group configuration for the private endpoint
  private_dns_zone_group {
    name                 = "${var.prefix}dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone.id]
  }
}

// Azure Private DNS Zone for the SQL Database
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

// Link between the Private DNS Zone and the Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "${var.prefix}vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}