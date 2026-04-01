terraform {  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

resource "azurerm_resource_group" "demo" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_virtual_network" "vnetlab" {
  name                = "vnet-lab"
  address_space       = var.vnet-labspace
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
}

resource "azurerm_subnet" "subnetlab" {
  name                 = "subnet-lab"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.vnetlab.name
  address_prefixes     = ["10.0.1.0/24"]
}