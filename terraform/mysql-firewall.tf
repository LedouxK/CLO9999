# Règle de pare-feu pour autoriser Azure App Service
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_app_service" {
  name                = "allow-app-service"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"  # Autorise tous les services Azure
}

# Règle pour autoriser Azure Services
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "allow-azure-services"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Nous ajouterons les règles pour App Service plus tard
# resource "azurerm_mysql_flexible_server_firewall_rule" "app_service" {
#   count               = length(split(",", azurerm_linux_web_app.app.outbound_ip_addresses))
#   name                = "allow-app-service-${count.index}"
#   resource_group_name = azurerm_resource_group.rg.name
#   server_name         = azurerm_mysql_flexible_server.mysql.name
#   start_ip_address    = element(split(",", azurerm_linux_web_app.app.outbound_ip_addresses), count.index)
#   end_ip_address      = element(split(",", azurerm_linux_web_app.app.outbound_ip_addresses), count.index)
# } 