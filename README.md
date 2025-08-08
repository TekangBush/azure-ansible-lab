Ansible control node and two hosts( Linux and Windows) configuration.

Instructions to set up Ansible control Node  & control Windows Host and Linux Host

Ansible Documentation Reference =====> https://docs.ansible.com/ansible/latest/os_guide/windows_winrm.html#windows-winrm

ssh On the Ubuntu Ansible Controller, install :

Ansible Controller


# Run these commands inside Ubuntu 


sudo apt-get update -y

sudo apt-add-repository -y ppa:ansible/ansible

sudo apt-get update -y

sudo apt-get install ansible

ansible --version (checking if ansible is installed or not)

# Let us try some adhoc commands against localhost 

ansible localhost -m "ping"

ansible localhost -a "hostname"


# Install WinRM package (Python client for Windows Remote Management)===> This is needed on ansible controller to be able to talk to Windows host

sudo apt-get -y install python3-winrm

Windows Machine

Open Powershell with Administrator Privilege and run the following

# Modify firewall rule to let in IPv4 and IPv6 traffic
Enable-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (Echo Request - ICMPv4-In)'
Enable-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (Echo Request - ICMPv6-In)'


# Follow WinRM instructions from Ansible Documentation

https://docs.ansible.com/ansible/latest/os_guide/windows_winrm.html#winrm-setup
```powershell
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
