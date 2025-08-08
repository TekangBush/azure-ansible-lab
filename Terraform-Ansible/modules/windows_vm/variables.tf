variable "name" {
  description = "The name to be used for the virtual machine and related resources."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "rg_name" {
  description = "The name of the existing Resource Group where the resources will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to which the network interface will be attached."
  type        = string
}

# variable "vnet_name" {
#   description = "The name for the Azure Virtual Network."
#   type        = string
# }

variable "admin_password" {
  description = "The admin password for the Windows Virtual Machine."
  type        = string
  sensitive   = true 
}
