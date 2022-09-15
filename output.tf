output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.myterraformvm.public_ip_address
}

output "domain_name_label" {
  value = azurerm_public_ip.myterraformpublicip.fqdn
}

output "admin_password" {
  value = random_password.linux-vm-password.result
  sensitive = true
}

# terraform output admin_password
