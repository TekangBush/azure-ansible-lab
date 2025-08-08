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
