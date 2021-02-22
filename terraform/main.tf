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
  name                     = regex("[a-z]+","${var.name_prefix}flaskcvwebacr")
  resource_group_name      = azurerm_resource_group.azure_cv.name
  location                 = azurerm_resource_group.azure_cv.location
  sku                      = "Basic"
  admin_enabled            = false
}

# Create Azure ACI Container Group
resource "azurerm_container_group" "azure_cv" {
  name                = "${var.name_prefix}-flask-cv-web"
  location            = azurerm_resource_group.azure_cv.location
  resource_group_name = azurerm_resource_group.azure_cv.name
  ip_address_type     = "public"
  dns_name_label      = "${var.name_prefix}-flask-cv-web"
  os_type             = "Linux"

  container {
    name                         = "${var.name_prefix}-flask-cv-web"
    image                        = "${var.docker_login_server}/${var.container_name}:${var.container_tag}"
    cpu                          = "0.25"
    memory                       = "0.3"
    commands                     = ["python", "app.py", "run", "-h", "0.0.0.0"]
    environment_variables        = { "END_POINT" = var.end_point }
    secure_environment_variables = { "SUBSCRIPTION_KEY" = var.subscrition_key }

    ports {
      port     = 5000
      protocol = "TCP"
    }
  }

  tags = {
    environment = "${var.name_prefix}_Azure_CV"
  }
}