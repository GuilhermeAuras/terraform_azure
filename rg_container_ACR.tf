provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg"
  location = "brazilsouth"
}

resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry666Terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "admin-usuario" {
  value = azurerm_container_registry.acr.admin_username
}

output "admin-senha" {
  value = azurerm_container_registry.acr.admin_password
  sensitive = true
}
