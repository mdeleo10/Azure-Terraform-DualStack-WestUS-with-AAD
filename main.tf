# Terraform GitHub storage account for state output
terraform {
  backend "azurerm" {
    resource_group_name     = "rg-terraform-state-001"
    storage_account_name    = "cloudmdterraformstate"
    container_name          = "tfstate"
    key                     = "tfstate"
  }
}

# Terraform GitHub storage account for state output
#
#
# Create Storage Account Container
# Suggestion: create tfstate-repo-name, needs to be lower case only
#
# az storage container create -n tftstate-azure-terraform-dualstack-brazilsouth --account-name  cloudmdterraformstate
#
#terraform {
#  backend "azurerm" {
#    resource_group_name     = "rg-terraform-state-001"
#    storage_account_name    = "cloudmdterraformstate"
#    container_name          = "tftstate-azure-terraform-dualstack-brazilsouth"
#    key                     = "tfstate"
#  }
#}


#Referencing EXISTING Azure Keyvault for secrets
#Service Principal or user needs to have RBAC permissions in IAM for keyvaul such as Keyvault administrator
data "azurerm_key_vault" "kv-terraform-script-001" {
  name                = "kv-terraform-script-001"
  resource_group_name = "rg-terraform-state-001"
}

#Referencing the EXISTING ssh key secret in the Keyvault Above
data "azurerm_key_vault_secret" "sshIDpub" {
  name         = "sshIDpub"
  key_vault_id = data.azurerm_key_vault.kv-terraform-script-001.id
}

# Generate random password
resource "random_password" "linux-vm-password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}


# Define Resource Group Name
resource "azurerm_resource_group" "rg" {
  name      = "${var.resource_group_name_prefix}-${var.resource_group_location}"
  location  = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "ubuntu-Vnet-${var.resource_group_location}"
  address_space       = "${var.vnet-address-space}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "ubuntu-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = "${var.vnet-address-space-subnet}"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "ubuntu-PublicIP-${var.resource_group_location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "vmdualstack100002"
}

# Create public IPv6s

resource "azurerm_public_ip" "myterraformpublicipv6" {
  name                = "ubuntu-PublicIPv6-${var.resource_group_location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  ip_version          = "IPv6"
  sku                 = "Standard"
  domain_name_label   = "vmdualstack100002"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "ubuntu-NetworkSecurityGroup-${var.resource_group_location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 
  security_rule {
    name                       = "Http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Https"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "ICMP"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "ubuntu-NIC-${var.resource_group_location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ubuntu-NicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    primary                                       = true
  }

  ip_configuration {
    name                          = "ubuntu-NicConfigurationv6"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv6"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicipv6.id
    }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


data "template_file" "azure-ubuntu-boot" {
    template = file("azure-ubuntu-boot.sh")
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "ubuntu-${var.resource_group_location}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "ubuntu--${var.resource_group_location}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

# To review the latest available image:
#   az vm image list --all --publisher Canonical | \
#      jq '[.[] | select(.sku=="22_04-lts")]| max_by(.version)'
#
  source_image_reference {
    publisher  = "Canonical"
    offer      = "0001-com-ubuntu-server-jammy"
    sku        = "22_04-lts"
    version    = "latest"
  }

  computer_name                       = azurerm_resource_group.rg.location
  admin_username                      = var.admin_username
  admin_password                      = random_password.linux-vm-password.result
#  admin_password                      = var.admin_password

# Managed System Identity for Azure Active Directory access
# Need to add AADSSHLoginForLinux extenstion for AAD User Authentication
# Also need to add users to role: Virtual Machine User Login and optional Virtual Machine User Admin at
#   resource group or higher
  identity {
      type      = "SystemAssigned"
  }

# Disabled for staging, Enable for Production
#  disable_password_authentication    = true
  disable_password_authentication     = false

# Custom Data is equivalent to "cloud-init" bootstrapping
  custom_data                         = base64encode(data.template_file.azure-ubuntu-boot.rendered)

  admin_ssh_key {
    username = var.admin_username
    public_key = "${data.azurerm_key_vault_secret.sshIDpub.value}" 
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }
  
  tags = {
    environment = "Test"
  }
  
}


resource "azurerm_virtual_machine_extension" "myterraformext" {
  name                 = azurerm_resource_group.rg.location
  virtual_machine_id   = azurerm_linux_virtual_machine.myterraformvm.id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADSSHLoginForLinux"
  type_handler_version = "1.0"

  tags = {
    environment = "Production"
  }
}
