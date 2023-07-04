variable "resource_group_name_prefix" {
  default       = "rg-DualStack"
  description   = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  default       = "westus3"
  description   = "Location of the resource group."
}

variable "admin_username" {
  default       = "mdeleo"
  description   = "Administrator Username"
}

variable "vnet-address-space" {
  type          = list
  default       = ["10.0.0.0/16","ace:cab:deca::/48"]
  description   = "Vnet Address Space"
}

variable "vnet-address-space-subnet"  {
  type          = list
  default       = ["10.0.1.0/24","ace:cab:deca:1::/64"]
  description   = "Subnet Address Space"
}
