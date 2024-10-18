resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.credifyai.location
  resource_group_name = data.azurerm_resource_group.credifyai.name
}

resource "azurerm_subnet" "nodes" {
  name                 = "nodes"
  resource_group_name  = data.azurerm_resource_group.credifyai.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "pods" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.credifyai.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "aks-pod-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}