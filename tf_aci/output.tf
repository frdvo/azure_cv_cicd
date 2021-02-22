# Show deployment URL

output "url" {
  value = "http://${azurerm_container_group.azure_cv.fqdn}:5000/upload-image"
}