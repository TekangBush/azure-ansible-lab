variable "location" {
  default = "eastus"
}

variable "rg_name" {
  default = "ansible-lab-rg"
}

variable "ssh_key_path" {
  default = "./metrc_key.pub"
}

variable "windows_password" {
  description = "Admin password for Windows VM"
  sensitive   = true
}
variable "vnet_name" {
  default = "metrc_vnet"
}