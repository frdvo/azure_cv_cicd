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
  name     = "${local.name_prefix}-flask-cv-web-rg"
  location = local.location
}

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                     = regex("[a-z]+","${local.name_prefix}flaskcvwebacr")
  resource_group_name      = azurerm_resource_group.azure_cv.name
  location                 = azurerm_resource_group.azure_cv.location
  sku                      = "Basic"
  admin_enabled            = false
}

# Create Azure ACI Container Group
resource "azurerm_container_group" "azure_cv" {
  name                = "${local.name_prefix}-flask-cv-web"
  location            = azurerm_resource_group.azure_cv.location
  resource_group_name = azurerm_resource_group.azure_cv.name
  ip_address_type     = "public"
  dns_name_label      = "${local.name_prefix}-flask-cv-web"
  os_type             = "Linux"

  container {
    name                         = "${local.name_prefix}-flask-cv-web"
    image                        = "pedrojunqueira/flask-cv_web:latest"
    cpu                          = "0.25"
    memory                       = "0.3"
    commands                     = ["python", "app.py", "run", "-h", "0.0.0.0"]
    environment_variables        = { "END_POINT" = local.end_point }
    secure_environment_variables = { "SUBSCRIPTION_KEY" = local.subscrition_key }

    ports {
      port     = 5000
      protocol = "TCP"
    }
  }

  tags = {
    environment = "${local.name_prefix}_Azure_CV"
  }
}

# Show deployment URL
output "URL" {
  value = "http://${azurerm_container_group.azure_cv.fqdn}:5000/upload-image"
}