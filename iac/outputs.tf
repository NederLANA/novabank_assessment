# outputs.tf - values Terraform prints after 'apply' (handy for the demo)
# SAY: "Terraform hands me the URL and names I need - nothing to look up by hand."

output "api_url" {
  value       = "https://${azurerm_container_app.api.ingress[0].fqdn}"
  description = "Public URL of the catalogue API"
}

output "resource_group" {
  value = module.rg.groups.main.name
}

output "log_workspace" {
  value = azurerm_log_analytics_workspace.main.name
}

output "database_server" {
  value = azurerm_postgresql_flexible_server.main.name
}
