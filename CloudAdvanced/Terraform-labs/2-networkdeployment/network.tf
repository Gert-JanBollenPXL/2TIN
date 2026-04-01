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

// Resource group
resource "azurerm_resource_group" "rg-networktemplate" {
  name     = "rg-terraform-networktemplate"
  location = "North Europe"
}

// Virtual network
resource "azurerm_virtual_network" "vnet-networktemplate" {
  name                = "vnet-networktemplate"
  location            = azurerm_resource_group.rg-networktemplate.location
  resource_group_name = azurerm_resource_group.rg-networktemplate.name
  address_space       = ["172.16.0.0/16"]
}

// public subnet
resource "azurerm_subnet" "snet-public" {
  name                 = "snet-public"
  resource_group_name  = azurerm_resource_group.rg-networktemplate.name
  virtual_network_name = azurerm_virtual_network.vnet-networktemplate.name
  address_prefixes     = ["172.16.1.0/24"]
}

// private subnet
resource "azurerm_subnet" "snet-private" {
  name                 = "snet-private"
  resource_group_name  = azurerm_resource_group.rg-networktemplate.name
  virtual_network_name = azurerm_virtual_network.vnet-networktemplate.name
  address_prefixes     = ["172.16.2.0/24"]
  private_endpoint_network_policies = "Enabled"
}

// Public IP address
resource "azurerm_public_ip" "pip-networktemplate" {
  name                = "pip-natgw"
  resource_group_name = azurerm_resource_group.rg-networktemplate.name
  location            = azurerm_resource_group.rg-networktemplate.location
  allocation_method   = "Static"
}

// nat gateway
resource "azurerm_nat_gateway" "natgw-networktemplate" {
  name                    = "natgw-networktemplate"
  location                = azurerm_resource_group.rg-networktemplate.location
  resource_group_name     = azurerm_resource_group.rg-networktemplate.name
}

// nat gateway public ip association
resource "azurerm_nat_gateway_public_ip_association" "natgw-pip-association" {
  nat_gateway_id       = azurerm_nat_gateway.natgw-networktemplate.id
  public_ip_address_id = azurerm_public_ip.pip-networktemplate.id
}


// nat gateway subnet association
resource "azurerm_subnet_nat_gateway_association" "natgw-subnet-association" {
  subnet_id      = azurerm_subnet.snet-private.id
  nat_gateway_id = azurerm_nat_gateway.natgw-networktemplate.id
}

resource "azurerm_subnet_nat_gateway_association" "natgw-subnet-association" {
  subnet_id      = azurerm_subnet.snet-public.id
  nat_gateway_id = azurerm_nat_gateway.natgw-networktemplate.id
}