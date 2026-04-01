variable "rgname" {
  type        = string
  default     = "rg-terraform-demo"
}

variable "location" {
  type        = string
  default     = "westeurope"
}

variable "vnetname" {
  type        = string
  default     = "vnet-tflab"
}

variable "vnetaspace" {
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "snetname" {
  type        = string
  default     = "snet-tflab"
}

variable "snetaspace" {
  type        = list(string)
  default     = ["10.1.10.0/24"]
}

variable "vmname" {
  type        = string
  default     = "vm-terraform"
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
  default     = "./vm-tf-sshkey.pub"
}