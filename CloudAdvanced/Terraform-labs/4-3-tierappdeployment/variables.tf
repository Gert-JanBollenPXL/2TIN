variable "location" {
  default = "northeurope"
}

variable "resource_group_name" {
  default = "rg-subtrackerapp"
}

variable "vnet_name" {
  default = "vnet-subtracker"
}

variable "vnet_address_space" {
  default = "10.1.0.0/16"
}

variable "subnet_frontend_name" {
  default = "snet-frontend"
}

variable "subnet_frontend_prefix" {
  default = "10.1.10.0/24"
}

variable "subnet_backend_name" {
  default = "snet-backend"
}

variable "subnet_backend_prefix" {
  default = "10.1.20.0/24"
}

variable "subnet_database_name" {
  default = "snet-database"
}

variable "subnet_database_prefix" {
  default = "10.1.30.0/24"
}

variable "lb_public_ip_name" {
  default = "pip-loadb"
}

variable "nat_public_ip_name" {
  default = "pip-natgw"
}

variable "nat_gateway_name" {
  default = "natgw-subtracker"
}

variable "nsg_name" {
  default = "nsg-trackapp"
}