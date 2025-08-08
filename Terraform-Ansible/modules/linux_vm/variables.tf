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

variable "ssh_key_path" {
  description = "The path to the public SSH key file for the admin user."
  type        = string
}
