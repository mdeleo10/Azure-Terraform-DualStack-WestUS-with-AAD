# Terraform-DualStack-WestUS-with-AAD


Adding support for Azure Active Directory to Azure Linux

See https://docs.microsoft.com/en-us/azure/active-directory/devices/howto-vm-sign-in-azure-ad-linux and https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension

Notes for AAD:
1. Need to login using "az login"
2. Also need to add users to role: Virtual Machine User Login and optional Virtual Machine User Admin at resource group or higher
3. Remote access to the Linux host using "az ssh vm -n ubuntu-westus3 -g rg-DualStack-westus3".
4. You can optionally download the OpenSSH keys to directly "ssh" in from the OS "az ssh config --file ~/.ssh/config -n ubuntu-westus3 -g rg-DualStack-westus3"
5. If you going to automate operations on the host, it is best not use a user credential and best create a "Service Principal" with the limited RBAC rights.


