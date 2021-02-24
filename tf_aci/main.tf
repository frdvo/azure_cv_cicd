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

# Create Azure ACI Container Group
resource "azurerm_container_group" "azure_cv" {
  name                = "${var.name_prefix}-flask-cv-web"
  location            = var.location
  resource_group_name = var.rg_name
  ip_address_type     = "public"
  dns_name_label      = "${var.name_prefix}-flask-cv-web"
  os_type             = "Linux"

  image_registry_credential {
      username = "00000000-0000-0000-0000-000000000000"
      password = var.docker_access_token
      server   = var.docker_login_server

    }

  container {
    name                         = "${var.name_prefix}-flask-cv-web"
    image                        = "${var.docker_login_server}/${var.container_name}:${var.container_tag}"
    cpu                          = "0.25"
    memory                       = "0.3"
    environment_variables        = { "END_POINT" = var.end_point }
    secure_environment_variables = { "SUBSCRIPTION_KEY" = var.subscription_key }

    ports {
      port     = 5000
      protocol = "TCP"
    }
    
  }

  tags = {
    environment = "${var.name_prefix}_Azure_CV"
  }
}