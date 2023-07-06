# Azure-Terraform-DualStack-WestUS-with-AAD

This Azure Terraform template creates an Ubuntu latest version.

It has the following variables defined in the file variables.rf
- Resource Group Name
- Resource Region Location
- Admin Username
- Vnet Address Space
- Vnet Subnet Address Space

It is setup to run Actions upon code change and deploy

#Prerequistes:

Action Secrets:
- AZURE_AD_CLIENT_ID (Service Principal)
- AZURE_AD_CLIENT_SECRET (Password)
- AZURE_AD_TENANT_ID
- AZURE_SUBSCRIPTION_ID

Also needs an existing Resource Group rg-terraform-state-001
- Storage Account
- Key Vault with secret "sshIDpub" in the ssh public key string format example "ssh-rsa KKKKKKeyKKKKK userid@xxx.com"
Note: Storage Account must have IAM permissions for Storage Account contributor and Key Vault Administrator

## Create Resource Group
az group create -n tamopstfstates -l eastus
 
## Create Storage Account
az storage account create -n tamopstf0000 -g tamopstfstates -l eastus2 --sku Standard_LRS
 
## Create Storage Account Container
az storage container create -n tfstatedevops0000 

#Adding support for Azure Active Directory to Azure Linux

See https://docs.microsoft.com/en-us/azure/active-directory/devices/howto-vm-sign-in-azure-ad-linux and https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension

#Notes for AAD:
1. Need to login using "az login"
2. Also need to add users to role: Virtual Machine User Login and optional Virtual Machine Administrator Login at resource group or higher
3. Remote access to the Linux host using "az ssh vm -n ubuntu-westus3 -g rg-DualStack-westus3".
4. You can optionally download the OpenSSH keys to directly "ssh" in from the OS "az ssh config --file ~/.ssh/config -n ubuntu-westus3 -g rg-DualStack-westus3"
5. If you going to automate operations on the host, it is best not use a user credential and best create a "Service Principal" with the limited RBAC rights.


