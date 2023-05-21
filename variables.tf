variable "resource_group_name_prefix" {
  default       = "rg-DualStack-West"
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
