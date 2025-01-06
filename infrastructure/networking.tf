# Virtual Network for networking resources
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Database Subnet within the virtual network
resource "azurerm_subnet" "database_subnet" {
  name                 = "${var.prefix}-databasesubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Application Subnet within the virtual network
resource "azurerm_subnet" "app_subnet" {
  name                 = "${var.prefix}-appsubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  # Delegates the subnet to Microsoft Web Server Farms for hosting web applications
  delegation {
    name = "MicrosoftWebServerFarms"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# Application Gateway Subnet within the virtual network
resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "${var.prefix}-appgatewaysubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Resource for creating a static public IP address for the application
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

// Local variables for Application Gateway configuration
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"
  ssl_certificate_name           = "my-cert-1"
}

# Resource for creating Application Gateway
resource "azurerm_application_gateway" "app_gateway" {
  name                = "${var.prefix}-appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  # Configuration for the gateway's IP settings
  gateway_ip_configuration {
    name      = "${var.prefix}-gateway-ip-configuration"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  # Frontend port configuration for the application gateway
  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  # Frontend IP configuration linking to the public IP address
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  # SSL certificate to Application Gateway
  ssl_certificate {
    name     = local.ssl_certificate_name
    password = var.certificate_password
    data     = filebase64("${var.ssl_certificate}")
  }

  # Defines the backend address pool for the application gateway
  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = [azurerm_app_service.app_service.default_site_hostname]
  }

  # Configures the backend HTTP settings for the application gateway
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  # Configures the HTTP listener for the application gateway
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_name
  }

  # Defines the request routing rule for directing traffic to the backend
  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}