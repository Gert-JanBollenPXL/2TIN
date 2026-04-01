variable "rgname" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-terraform-demo"
}

variable "location" {
  type        = string
  default     = "westeurope"
}

variable "vnet-labspace" {
  type = list(string)
    default = ["10.0.0.0/16"]
}