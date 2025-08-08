provider "azurerm" {
  features {}
  subscription_id = "0e7350f3-1ba1-4191-9f49-d01f6132730b"
}
data "azurerm_resource_group" "metrc" {
  name = "metrc_rg"
}



module "metrc_network" {
  source    = "./modules/network"
  location  = data.azurerm_resource_group.metrc.location
  rg_name   = data.azurerm_resource_group.metrc.name
  vnet_name = var.vnet_name
}

module "controller" {
  source       = "./modules/linux_vm"
  name         = "ansible-controller"
  rg_name      = data.azurerm_resource_group.metrc.name
  location     = data.azurerm_resource_group.metrc.location
  subnet_id    = module.metrc_network.subnet_id
  ssh_key_path = var.ssh_key_path
}

module "linuxhost" {
  source       = "./modules/linux_vm"
  name         = "linux-host"
  rg_name      = data.azurerm_resource_group.metrc.name
  location     = data.azurerm_resource_group.metrc.location
  subnet_id    = module.metrc_network.subnet_id
  ssh_key_path = var.ssh_key_path
}

module "windowshost" {
  source         = "./modules/windows_vm"
  name           = "windows-host"
  rg_name        = data.azurerm_resource_group.metrc.name
  location       = data.azurerm_resource_group.metrc.location
  subnet_id      = module.metrc_network.subnet_id
  admin_password = var.windows_password
}
