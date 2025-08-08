
# Ansible control node and two hosts( Linux and Windows) configuration.

# Azure Resource Deployment Summary 
1. Network Infrastructure
 * A Virtual Network (10.0.0.0/16) named var.vnet_name.
 * A Subnet (10.0.1.0/24) named "metrc-subnet" within the VNet.
2. Virtual Machines
   * Linux VMs (2):
    
     * Ansible Controller: ansible-controller
    
     * Linux Host: linux-host
    
      * Both are Ubuntu Server 20.04 LTS VMs (Standard_B1s), using SSH key authentication, each with a Public IP and a Network Security Group allowing SSH (22), HTTP (80), and ICMP (ping) inbound.
    
   * Windows VM (1):
    
      * Windows Host: windows-host
    
       * A Windows Server 2019 Datacenter VM (Standard_DS1_v2), using password authentication, with a Public IP and a Network Security Group allowing ICMP (ping),          WinRM (5986), and RDP (3389) inbound.
3. Resource Group Context
   All resources are deployed into an existing Azure Resource Group named "metrc_rg"

# To creat Terraform resources in Azure run the following commands 
``` powershell
az login
az account set --tenant "AnotherTenantIdOrDomain"
```
# Run Terraform commands in the terraform working directory (where you have your main.tf file)
``` terraform 
terraform init # to initialize the terraform working directory
```
``` terraform 
terraform fmt -recursive # format terraform code
```
``` terraform 
terraform validate # to validate your code against syntax errors
```
``` terraform 
terraform plan # To view a plan of the resources that will be created
```
``` terraform 
terraform apply -auto-approve # to create the actual resource in Azure 
```
# Clean up 
``` terraform
terraform destroy -auto-approve
```
# Create ssh key to ssh into linux machines 
``` bash
ssh-keygen   # this creates two keys private and public keys and the public was copied into two linux machines for authentication
```
# copy private key to the ansible controller node 

# Instructions to set up Ansible control Node  & control Windows Host and Linux Host

# Ansible Documentation Reference =====> https://docs.ansible.com/ansible/latest/os_guide/windows_winrm.html#windows-winrm

# ssh On the Ubuntu Ansible Controller, install.
``` bash
scp <path to my metrc_key on my local machine> username@control_noded_hostname:~ (home of the control node)
 #Akeep this private key in a hidden folder .ssh
```
# Login to the ansible controller and follow the instructions below 
```bash
chmod 400 <private_key>
ssh -i <path to your private key> username@ip-address_ansible_control_node
```
# Ansible Controller
``` bash
# Run these commands inside Ubuntu (Windows WSL)
sudo apt-get update -y
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install ansible
ansible --version

# Let us try some adhoc commands against localhost
ansible localhost -m "ping"
ansible localhost -a "hostname"

# Install WinRM package (Python client for Windows Remote Management)
sudo apt-get -y install python3-winrm
```
# Windows Machine

# Open Powershell with Administrator Privilege and run the following
``` powershell
# Modify firewall rule to let in IPv4 and IPv6 traffic
Enable-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (Echo Request - ICMPv4-In)'
Enable-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (Echo Request - ICMPv6-In)'
```

# Follow WinRM instructions from Ansible Documentation

https://docs.ansible.com/ansible/latest/os_guide/windows_winrm.html#winrm-setup
``` powershell
# Enables the WinRM service and sets up the HTTP listener

Enable-PSRemoting -Force

# Opens port 5985 for all profiles

$firewallParams = @{
    Action      = 'Allow'
    Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]'
    Direction   = 'Inbound'
    DisplayName = 'Windows Remote Management (HTTP-In)'
    LocalPort   = 5985
    Profile     = 'Any'
    Protocol    = 'TCP'
}
New-NetFirewallRule @firewallParams

# Allows local user accounts to be used with WinRM
# This can be ignored if using domain accounts
$tokenFilterParams = @{
    Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Name        = 'LocalAccountTokenFilterPolicy'
    Value       = 1
    PropertyType = 'DWORD'
    Force       = $true
}
New-ItemProperty @tokenFilterParams
```

# Set up HTTPS with self-signed certificate
```powershell
## Create self signed certificate

$certParams = @{
    CertStoreLocation = 'Cert:\LocalMachine\My'
    DnsName           = $env:COMPUTERNAME
    NotAfter          = (Get-Date).AddYears(1)
    Provider          = 'Microsoft Software Key Storage Provider'
    Subject           = "CN=$env:COMPUTERNAME"
}
$cert = New-SelfSignedCertificate @certParams

#Create HTTPS listener
$httpsParams = @{
    ResourceURI = 'winrm/config/listener'
    SelectorSet = @{
        Transport = "HTTPS"
        Address   = "*"
    }
    ValueSet = @{
        CertificateThumbprint = $cert.Thumbprint
        Enabled               = $true
    }
}
New-WSManInstance @httpsParams

# Opens port 5986 for all profiles
$firewallParams = @{
    Action      = 'Allow'
    Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]'
    Direction   = 'Inbound'
    DisplayName = 'Windows Remote Management (HTTPS-In)'
    LocalPort   = 5986
    Profile     = 'Any'
    Protocol    = 'TCP'
}
New-NetFirewallRule @firewallParams
```
# Verify if the listeners are up & running
``` powershell
winrm enumerate winrm/config/Listener
```
# Output should be similar to the following:
```powershell
Listener
    Address = *
    Transport = HTTP
    Port = 5985
    Hostname
    Enabled = true
    URLPrefix = wsman
    CertificateThumbprint
    ListeningOn = 10.0.2.15, 127.0.0.1, 192.168.56.155, ::1, fe80::5efe:10.0.2.15%6, fe80::5efe:192.168.56.155%8, fe80::
ffff:ffff:fffe%2, fe80::203d:7d97:c2ed:ec78%3, fe80::e8ea:d765:2c69:7756%7

Listener
    Address = *
    Transport = HTTPS
    Port = 5986
    Hostname = SERVER2016
    Enabled = true
    URLPrefix = wsman
    CertificateThumbprint = E6CDAA82EEAF2ECE8546E05DB7F3E01AA47D76CE
    ListeningOn = 10.0.2.15, 127.0.0.1, 192.168.56.155, ::1, fe80::5efe:10.0.2.15%6, fe80::5efe:192.168.56.155%8, fe80::
ffff:ffff:fffe%2, fe80::203d:7d97:c2ed:ec78%3, fe80::e8ea:d765:2c69:7756%7
```
# To double confirm, you can also check the status of "Windows Remote Management (WS-Management)" service in the Windows "Services" UI!
# Now, check if you can ping (ICMP) your windows machine from Ansible Controller
``` bash
ping <IP-ADDRESS-OF-WINDOWS-MACHINE>
```
# Create an inventory (/etc/ansible/hosts) entry containing details of your Windows host and ubuntu host:
```bash
[windows_hosts]

windows-hosts ansible_host=10.0.1.4 ansible_user=azureuser ansible_password=ITMGXg5XnVKTe0I ansible_port=5986 ansible_winrm_transport=ntlm ansible_connection=winrm ansible_winrm_server_cert_validation=ignore

[linux_hosts]
linux-host ansible_host=10.0.1.5 ansible_user=azureuser ansible_ssh_private_key_file=~/metrc_key
```
# Run an adhoc command to check connectivity with Windows Host
``` bash
ansible windows-hosts -m win_ping
