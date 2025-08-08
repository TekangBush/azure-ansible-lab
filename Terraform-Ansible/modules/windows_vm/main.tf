resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.rg_name
  size                  = "Standard_DS1_v2"
  admin_username        = "azureuser"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  # # This provisioner creates a new outbound firewall rule on the Windows VM itself
  # # to allow ICMP traffic, which is required for ping to work.
  # provisioner "remote-exec" {
  #   # The 'host' argument is now included to specify the VM's public IP address.
  #   connection {
  #     type     = "winrm"
  #     host     = azurerm_public_ip.pip.ip_address
  #     user     = self.admin_username
  #     password = self.admin_password
  #   }
  #   inline = [
  #     "New-NetFirewallRule -DisplayName 'Allow Outbound Ping' -Direction Outbound -Protocol ICMPv4 -Action Allow",
  #     "Get-NetFirewallRule -DisplayName 'Allow Outbound Ping' | Format-List",
  #   ]
  # }
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.rg_name

  # New rule to allow inbound ICMP traffic (ping)
  security_rule {
    name                       = "allow_icmp"
    priority                   = 999
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    # Rule for WinRM traffic
    name                       = "allow_winrm"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986" # Port for WinRM
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    # Rule for RDP traffic
    name                       = "allow_rdp"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389" # Port for RDP
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
