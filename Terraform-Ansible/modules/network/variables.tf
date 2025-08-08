

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "rg_name" {
  description = "The name of the existing Resource Group where the resources will be deployed."
  type        = string
}



variable "vnet_name" {
  description = "The name for the Azure Virtual Network."
  type        = string
}
