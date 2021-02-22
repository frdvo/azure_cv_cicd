# Terraform required providers config
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Select Terraform Provider azurerm
provider "azurerm" {
  features {}
}

# Create Azure Resource Grop
resource "azurerm_resource_group" "azure_cv" {
  name     = "${var.name_prefix}-flask-cv-web-aci-rg"
  location = var.location
}

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = regex("[a-z]+", "${var.name_prefix}flaskcvwebacr")
  resource_group_name = azurerm_resource_group.azure_cv.name
  location            = azurerm_resource_group.azure_cv.location
  sku                 = "Basic"
  admin_enabled       = false
}