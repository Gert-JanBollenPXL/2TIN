variable "location" {
  type        = string
  default = "northeurope"
}

variable "resource_group_name" {
  type        = string
  default = "IACGert-JanBollen"
}

variable "vnet_name" {
  type        = string
  default = "vnet-general"
}

variable "vnet_address_space" {
  type        = list(string)
  default = ["192.168.0.0/16"]
}

variable "subnet_frontend_name" {
  type        = string
  default = "snet-frontend"
}

variable "subnet_frontend_prefix" {
  type        = list(string)
  default = ["192.168.10.0/24"]
}

variable "nat_public_ip_name" {
  type        = string
  default = "pip-natgw"
}

variable "nat_gateway_name" {
  type        = string
  default = "natgw-IAC"
}

variable "vmname" {
  type        = string
  default     = "vm-frontend"
}

variable "vmsize" {
  type        = string
  default     = "Standard_B2ts_V2"
}

variable "username" {
  type        = string
  default     = "azureuser"
}

variable "storagetype" {
  type        = string
  default     = "Premium_LRS"
}

variable "sshpubkey" {
  type        = string
  default     = "./vm-frontend-sshkey.pub"
}