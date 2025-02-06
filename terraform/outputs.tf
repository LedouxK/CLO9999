output "app_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "mysql_server_fqdn" {
  value = azurerm_mysql_flexible_server.mysql.fqdn
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "github_action_url" {
  value = "https://github.com/${var.github_organization}/${var.github_repository}/actions"
} 