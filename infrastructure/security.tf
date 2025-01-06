// Resource block for the application subnet's network security group
resource "azurerm_network_security_group" "app_subnet_nsg" {
  name                = "${var.prefix}-app-subnet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  // Allow traffic from the Application Gateway on port 443
  security_rule {
    name                       = "Allow-Application-Gateway"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  // Allow SQL access from the application subnet to the database on port 1433
  security_rule {
    name                       = "Allow-SQL-Access"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.database_subnet.address_prefixes[0]
  }

  // Allow internal communication within the application subnet
  security_rule {
    name                       = "Allow-Internal-Communication"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// Resource block for the application gateway subnet's network security group
resource "azurerm_network_security_group" "app_gateway_subnet_nsg" {
  name                = "${var.prefix}-app-gateway-subnet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  // Allow HTTPS traffic to the application gateway on port 443
  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  // Allow internal communication within the application gateway subnet
  security_rule {
    name                       = "Allow-Internal-Communication"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  // Allow health check traffic on port 65530
  security_rule {
    name                       = "Allow-Health-Checks"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65530"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// Resource block for the database subnet's network security group
resource "azurerm_network_security_group" "database_subnet_nsg" {
  name                = "${var.prefix}-database-subnet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  // Allow SQL access from the application subnet to the database on port 1433
  security_rule {
    name                       = "Allow-SQL-Access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = azurerm_subnet.app_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }

  // Allow access for private endpoints on port 1433
  security_rule {
    name                       = "Allow-Private-Endpoint-Access"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  // Deny all other inbound traffic
  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// Resource block for associating the application subnet with its network security group
resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
}

// Resource block for associating the application gateway subnet with its network security group
resource "azurerm_subnet_network_security_group_association" "app_gateway_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.app_gateway_subnet.id
  network_security_group_id = azurerm_network_security_group.app_gateway_subnet_nsg.id
}

// Resource block for associating the database subnet with its network security group
resource "azurerm_subnet_network_security_group_association" "database_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.database_subnet.id
  network_security_group_id = azurerm_network_security_group.database_subnet_nsg.id
}
