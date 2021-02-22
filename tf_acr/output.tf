# Show ACR Name deployment URL
output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "rg_name" {
  value = azurerm_resource_group.azure_cv.name

}