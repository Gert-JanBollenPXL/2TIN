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

// resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rgname
  location = var.location
}

// virtual network
resource "azurerm_virtual_network" "vneta" {
  name                = var.vnetname
  address_space       = var.vnetaspace
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

// subnet
resource "azurerm_subnet" "sneta" {
  name                 = var.snetname
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vneta.name
  address_prefixes     = var.snetaspace
}

// network interface
resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sneta.id
    private_ip_address_allocation = "Dynamic"
  }
}

// virtual machine
resource "azurerm_linux_virtual_machine" "vm-terraform" {
  name                = var.vmname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vmsize
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = var.username
    public_key = file(var.sshpubkey)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storagetype
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}